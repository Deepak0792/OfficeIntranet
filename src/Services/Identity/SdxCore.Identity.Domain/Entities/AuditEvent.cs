using SdxCore.SharedKernel.Entities;

namespace SdxCore.Identity.Domain.Entities;

/// <summary>
/// Domain entity representing an authentication audit event.
/// Records all authentication attempts for compliance and security monitoring.
/// This is an append-only record — audit events should never be modified or deleted.
/// </summary>
public sealed class AuditEvent : BaseEntity<Guid>
{
    /// <summary>Type of authentication event (e.g. LOGIN_SUCCESS, LOGIN_FAILURE, TOKEN_REFRESH).</summary>
    public required string EventType { get; init; }

    /// <summary>Authentication protocol used for this attempt (e.g. INHOUSE, SAML, OAUTH, OIDC).</summary>
    public required string Protocol { get; set; }

    /// <summary>
    /// Cross-schema FK to employee.Employee — the employee being authenticated.
    /// May be null for failed attempts where the user was not found.
    /// </summary>
    public Guid? EmployeeId { get; init; }

    /// <summary>Username submitted in the authentication request. May be null for non-username protocols.</summary>
    public string? Username { get; init; }

    /// <summary>IP address of the client making the authentication request (nullable — may not be available in all flows).</summary>
    public string? IpAddress { get; init; }

    /// <summary>Timestamp when the authentication event occurred. Maps to SQL column OccurredAt.</summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Reason for authentication failure. Null for successful authentications.</summary>
    public string? FailureReason { get; init; }
}