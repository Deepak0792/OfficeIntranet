using Microsoft.AspNetCore.Http;
using SdxCore.SharedKernel.Abstractions;
namespace SdxCore.SharedKernel.Contexts;
public class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContext(IHttpContextAccessor http)
    {
        _httpContextAccessor = http;
    }

    private HttpContext? Http => _httpContextAccessor.HttpContext;

    public bool IsAuthenticated =>
        !string.IsNullOrEmpty(Http?.Request?.Headers["X-User-Id"]);

    public Guid? UserId
    {
        get
        {
            var value = _httpContextAccessor.HttpContext?
                .Request
                .Headers["X-User-Id"]
                .FirstOrDefault();

            return Guid.TryParse(value, out var id) ? id : null;
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