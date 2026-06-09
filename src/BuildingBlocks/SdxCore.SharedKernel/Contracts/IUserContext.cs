namespace SdxCore.SharedKernel.Contracts;
public interface IUserContext
{
    Guid? UserId { get; }

    string? Username { get; }

    string? Email { get; }

    string? Roles { get; }

    string? IpAddress { get; }

    string? UserAgent { get; }

    string? Device { get; }

    string? TraceId { get; }

    string? CorrelationId { get; }

    bool IsAuthenticated { get; }
}
