using Microsoft.Extensions.Configuration;
using Microsoft.Net.Http.Headers;

namespace SdxCore.Attendance.Application.Clients;

/// <summary>
/// Adds the internal API key header to all outbound HTTP requests.
/// Registered as a DelegatingHandler for IEmployeeClient and ITimeClient.
/// </summary>
public class InternalApiKeyHandler(IConfiguration configuration) : DelegatingHandler
{
    private readonly string _apiKey = configuration["Authentication:InternalApiKey"]
        ?? throw new InvalidOperationException("InternalApiKey is not configured.");

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        request.Headers.TryAddWithoutValidation("X-Internal-ApiKey", _apiKey);
        return base.SendAsync(request, cancellationToken);
    }
}
