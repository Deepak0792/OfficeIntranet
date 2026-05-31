using Microsoft.AspNetCore.Http;
using SdxCore.Common.Interfaces.Contexts;
namespace SdxCore.Common.Contexts;
public class RequestContext : IRequestContext
{
    private readonly IHttpContextAccessor _http;

    public RequestContext(IHttpContextAccessor http)
    {
        _http = http;
    }

    private HttpContext? Http => _http.HttpContext;

    public bool IsAuthenticated =>
        !string.IsNullOrEmpty(Http?.Request?.Headers["X-User-Id"]);

    public int? UserId
    {
        get
        {
            var value = Http?.Request?.Headers["X-User-Id"].FirstOrDefault();
            return int.TryParse(value, out var userId) ? userId : null;
        }
    }

    public string? Username =>
        Http?.Request?.Headers["X-Username"].FirstOrDefault();

    public string? Email =>
        Http?.Request?.Headers["X-User-Email"].FirstOrDefault();

    public string? Roles =>
        Http?.Request?.Headers["X-User-Roles"].FirstOrDefault();

    public string? IpAddress
    {
        get
        {
            var http = Http;
            if (http == null) return null;

            // 1. Gateway-provided IP (preferred)
            var clientIp = http.Request.Headers["X-Client-Ip"].FirstOrDefault();

            if (!string.IsNullOrWhiteSpace(clientIp))
                return clientIp;

            // 2. Fallback: X-Forwarded-For
            var forwarded = http.Request.Headers["X-Forwarded-For"].FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(forwarded))
                return forwarded.Split(',')[0].Trim();

            // 3. Fallback: direct connection IP
            return http.Connection.RemoteIpAddress?.ToString();
        }
    }

    public string? UserAgent =>
        Http?.Request?.Headers["X-User-Agent"].FirstOrDefault();

    public string? Device =>
        Http?.Request?.Headers["X-Device"].FirstOrDefault();

    public string? TraceId =>
        Http?.Request?.Headers["X-Trace-Id"].FirstOrDefault()
        ?? Http?.TraceIdentifier;

    public string? CorrelationId =>
        Http?.Request?.Headers["X-Correlation-Id"].FirstOrDefault()
        ?? TraceId;
}