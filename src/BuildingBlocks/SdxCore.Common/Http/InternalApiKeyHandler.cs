using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Abstractions;

namespace SdxCore.Common.Http;

/// <summary>
/// DelegatingHandler that attaches the internal API key and propagates user context headers
/// on outbound service-to-service HTTP calls.
/// </summary>
public class InternalApiKeyHandler : DelegatingHandler
{
    private readonly IConfiguration _configuration;
    private readonly IUserContext _requestContext;
    private readonly ILogger<InternalApiKeyHandler> _logger;

    public InternalApiKeyHandler(
        IConfiguration configuration,
        IUserContext requestContext,
        ILogger<InternalApiKeyHandler> logger)
    {
        _configuration = configuration;
        _requestContext = requestContext;
        _logger = logger;
    }

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        AttachInternalApiKey(request);
        PropagateUserHeaders(request);

        return base.SendAsync(request, cancellationToken);
    }

    private void AttachInternalApiKey(HttpRequestMessage request)
    {
        var key = _configuration["Authentication:InternalApiKey"];

        if (string.IsNullOrWhiteSpace(key))
        {
            _logger.LogError("Internal API key not configured");
            throw new InvalidOperationException("Internal API key missing");
        }

        request.Headers.Remove("X-Internal-API-Key");
        request.Headers.Add("X-Internal-API-Key", key);
    }

    private void PropagateUserHeaders(HttpRequestMessage request)
    {
        AddHeader(request, "X-User-Id", _requestContext.UserId?.ToString());
        AddHeader(request, "X-Username", _requestContext.Username);
        AddHeader(request, "X-User-Email", _requestContext.Email);
        AddHeader(request, "X-User-Roles", _requestContext.Roles);
        AddHeader(request, "X-Client-Ip", _requestContext.IpAddress);
        AddHeader(request, "X-User-Agent", _requestContext.UserAgent);
        AddHeader(request, "X-Device", _requestContext.Device);
        AddHeader(request, "X-Trace-Id", _requestContext.TraceId);
        AddHeader(request, "X-Correlation-Id", _requestContext.CorrelationId);
    }

    private static void AddHeader(HttpRequestMessage request, string key, string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return;

        request.Headers.Remove(key);
        request.Headers.Add(key, value);
    }
}
