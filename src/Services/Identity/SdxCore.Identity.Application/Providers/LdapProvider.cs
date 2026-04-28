using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Novell.Directory.Ldap;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// LDAP / Active Directory authentication provider.
/// Performs bind operations against LDAP directories with LDAPS encryption by default.
/// </summary>
/// <remarks>
/// This provider implements requirements 3.4, 13.1-13.4:
/// - 3.4: Performs LDAP bind operation for authentication
/// - 13.1: Uses LDAPS (LDAP over TLS) by default
/// - 13.2: Rejects plain LDAP unless explicitly enabled in configuration
/// - 13.3: Verifies server certificate is valid and trusted
/// - 13.4: Closes and disposes connection after operation
/// </remarks>
public sealed class LdapProvider : IAuthenticationProvider
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<LdapProvider> _logger;

    // Configuration keys
    private const string ServerKey = "Ldap:Server";
    private const string PortKey = "Ldap:Port";
    private const string BaseDnKey = "Ldap:BaseDn";
    private const string UseSslKey = "Ldap:UseSsl";
    private const string AllowPlainLdapKey = "Ldap:AllowPlainLdap";
    private const string SearchFilterKey = "Ldap:SearchFilter";
    private const string ConnectionTimeoutKey = "Ldap:ConnectionTimeoutSeconds";

    /// <summary>
    /// Initializes a new instance of the <see cref="LdapProvider"/> class.
    /// </summary>
    /// <param name="configuration">Application configuration.</param>
    /// <param name="logger">Logger instance.</param>
    public LdapProvider(
        IConfiguration configuration,
        ILogger<LdapProvider> logger)
    {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        // Validate required configuration
        ValidateConfiguration();
    }

    /// <inheritdoc />
    public AuthProtocol Protocol => AuthProtocol.Ldap;

    /// <inheritdoc />
    public async Task<ProviderResult> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        // 1. Validate input (Requirement 3.4)
        if (string.IsNullOrWhiteSpace(request.Username))
        {
            _logger.LogWarning("LDAP authentication attempt with missing username");
            return Fail("Username is required for LDAP authentication.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("LDAP authentication attempt with missing password");
            return Fail("Password is required for LDAP authentication.");
        }

        // 2. Read configuration
        string server = _configuration[ServerKey]!;
        int port = int.Parse(_configuration[PortKey] ?? "636"); // Default LDAPS port
        string baseDn = _configuration[BaseDnKey]!;
        bool useSsl = bool.Parse(_configuration[UseSslKey] ?? "true");
        bool allowPlainLdap = bool.Parse(_configuration[AllowPlainLdapKey] ?? "false");
        string searchFilter = _configuration[SearchFilterKey] ?? "(uid={0})";
        int connectionTimeout = int.Parse(_configuration[ConnectionTimeoutKey] ?? "30");

        // 3. Enforce LDAPS by default (Requirements 13.1, 13.2)
        if (!useSsl && !allowPlainLdap)
        {
            _logger.LogError("Plain LDAP connection attempted but not explicitly allowed in configuration");
            return Fail("Plain LDAP connections are not allowed. Please enable LDAPS or explicitly allow plain LDAP in configuration.");
        }

        if (!useSsl)
        {
            _logger.LogWarning("Plain LDAP connection is being used. This is not recommended for production environments.");
        }

        LdapConnection? connection = null;

        try
        {
            // 4. Create LDAP connection with connection pooling support
            connection = new LdapConnection();
            connection.ConnectionTimeout = connectionTimeout * 1000; // Convert to milliseconds

            // 5. Connect to LDAP server (Requirement 13.1: Use LDAPS)
            await Task.Run(() =>
            {
                if (useSsl)
                {
                    // Requirement 13.3: Verify server certificate
                    // The Novell.Directory.Ldap library validates certificates by default
                    connection.SecureSocketLayer = true;
                }

                _logger.LogDebug("Connecting to LDAP server: {Server}:{Port} (SSL: {UseSsl})", server, port, useSsl);
                connection.Connect(server, port);
            }, ct);

            // 6. Construct user DN for bind operation
            string userDn = ConstructUserDn(request.Username, baseDn, searchFilter);

            // 7. Perform bind operation (Requirement 3.4)
            await Task.Run(() =>
            {
                _logger.LogDebug("Attempting LDAP bind for user: {UserDn}", userDn);
                connection.Bind(userDn, request.Password);
            }, ct);

            // 8. If bind succeeds, extract user claims
            var claims = await ExtractUserClaimsAsync(connection, userDn, request.Username, ct);

            _logger.LogInformation("Successful LDAP authentication for user: {Username}", request.Username);

            return new ProviderResult
            {
                IsSuccess = true,
                Claims = claims
            };
        }
        catch (LdapException ex) when (ex.ResultCode == LdapException.INVALID_CREDENTIALS)
        {
            // Invalid credentials - return generic error to prevent user enumeration
            _logger.LogWarning("LDAP authentication failed for user: {Username} - Invalid credentials", request.Username);
            return Fail("Invalid credentials.");
        }
        catch (LdapException ex) when (ex.ResultCode == LdapException.NO_SUCH_OBJECT)
        {
            // User not found - return generic error to prevent user enumeration
            _logger.LogWarning("LDAP authentication failed for user: {Username} - User not found", request.Username);
            return Fail("Invalid credentials.");
        }
        catch (LdapException ex) when (ex.ResultCode == LdapException.CONNECT_ERROR)
        {
            _logger.LogError(ex, "Failed to connect to LDAP server: {Server}:{Port}", server, port);
            return Fail("LDAP server is unavailable.");
        }
        catch (LdapException ex)
        {
            _logger.LogError(ex, "LDAP authentication error for user: {Username} - ResultCode: {ResultCode}", 
                request.Username, ex.ResultCode);
            return Fail("LDAP authentication failed.");
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("LDAP authentication cancelled for user: {Username}", request.Username);
            return Fail("Authentication operation was cancelled.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during LDAP authentication for user: {Username}", request.Username);
            return Fail("An unexpected error occurred during authentication.");
        }
        finally
        {
            // Requirement 13.4: Close and dispose connection after operation
            if (connection != null)
            {
                try
                {
                    if (connection.Connected)
                    {
                        connection.Disconnect();
                    }
                    connection.Dispose();
                    _logger.LogDebug("LDAP connection closed and disposed");
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while closing LDAP connection");
                }
            }
        }
    }

    /// <summary>
    /// Constructs the user DN for bind operation.
    /// </summary>
    /// <param name="username">Username provided by the user.</param>
    /// <param name="baseDn">Base DN from configuration.</param>
    /// <param name="searchFilter">Search filter template from configuration.</param>
    /// <returns>Fully qualified user DN.</returns>
    private string ConstructUserDn(string username, string baseDn, string searchFilter)
    {
        // If the search filter contains a placeholder, replace it with the username
        if (searchFilter.Contains("{0}"))
        {
            string filter = string.Format(searchFilter, username);
            // For simple filters like (uid={0}), extract the attribute name
            // Example: (uid=john) -> uid=john,baseDn
            if (filter.StartsWith("(") && filter.EndsWith(")"))
            {
                filter = filter.Substring(1, filter.Length - 2);
            }
            return $"{filter},{baseDn}";
        }

        // If username already contains DN components, use it as-is with baseDn
        if (username.Contains("="))
        {
            return username.Contains(baseDn) ? username : $"{username},{baseDn}";
        }

        // Default: assume CN attribute
        return $"cn={username},{baseDn}";
    }

    /// <summary>
    /// Extracts user claims from LDAP directory after successful bind.
    /// </summary>
    /// <param name="connection">Active LDAP connection.</param>
    /// <param name="userDn">User's distinguished name.</param>
    /// <param name="username">Username.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>List of claims extracted from LDAP attributes.</returns>
    private async Task<List<Claim>> ExtractUserClaimsAsync(
        LdapConnection connection,
        string userDn,
        string username,
        CancellationToken ct)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, userDn),
            new Claim(ClaimTypes.Name, username),
            new Claim("sub", userDn)
        };

        try
        {
            // Search for user entry to extract additional attributes
            var searchResults = await Task.Run(() =>
            {
                var results = connection.Search(
                    userDn,
                    LdapConnection.SCOPE_BASE,
                    "(objectClass=*)",
                    new[] { "mail", "displayName", "cn", "sn", "givenName", "memberOf" },
                    false
                );
                return results;
            }, ct);

            if (searchResults.HasMore())
            {
                var entry = searchResults.Next();

                // Extract email
                var mailAttr = entry.getAttribute("mail");
                if (mailAttr != null)
                {
                    claims.Add(new Claim(ClaimTypes.Email, mailAttr.StringValue));
                }

                // Extract display name
                var displayNameAttr = entry.getAttribute("displayName");
                if (displayNameAttr != null)
                {
                    claims.Add(new Claim(ClaimTypes.GivenName, displayNameAttr.StringValue));
                }

                // Extract common name
                var cnAttr = entry.getAttribute("cn");
                if (cnAttr != null && cnAttr.StringValue != username)
                {
                    claims.Add(new Claim("cn", cnAttr.StringValue));
                }

                // Extract surname
                var snAttr = entry.getAttribute("sn");
                if (snAttr != null)
                {
                    claims.Add(new Claim(ClaimTypes.Surname, snAttr.StringValue));
                }

                // Extract given name
                var givenNameAttr = entry.getAttribute("givenName");
                if (givenNameAttr != null)
                {
                    claims.Add(new Claim("givenName", givenNameAttr.StringValue));
                }

                // Extract group memberships
                var memberOfAttr = entry.getAttribute("memberOf");
                if (memberOfAttr != null)
                {
                    foreach (var value in memberOfAttr.StringValueArray)
                    {
                        claims.Add(new Claim(ClaimTypes.Role, value));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to extract additional claims for user: {UserDn}. Using basic claims only.", userDn);
            // Continue with basic claims if attribute extraction fails
        }

        return claims;
    }

    /// <summary>
    /// Validates that required LDAP configuration is present.
    /// </summary>
    private void ValidateConfiguration()
    {
        string? server = _configuration[ServerKey];
        if (string.IsNullOrWhiteSpace(server))
        {
            throw new InvalidOperationException($"LDAP configuration is missing required key: {ServerKey}");
        }

        string? baseDn = _configuration[BaseDnKey];
        if (string.IsNullOrWhiteSpace(baseDn))
        {
            throw new InvalidOperationException($"LDAP configuration is missing required key: {BaseDnKey}");
        }

        _logger.LogInformation("LDAP provider initialized with server: {Server}", server);
    }

    /// <summary>
    /// Builds a failure result with the specified reason.
    /// </summary>
    /// <param name="reason">Failure reason.</param>
    /// <returns>Provider result indicating failure.</returns>
    private static ProviderResult Fail(string reason)
    {
        return new ProviderResult
        {
            IsSuccess = false,
            FailureReason = reason
        };
    }
}
