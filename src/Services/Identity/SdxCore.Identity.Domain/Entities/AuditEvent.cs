namespace SdxCore.Identity.Domain.Entities;

/// <summary>
/// Domain entity representing an authentication audit event.
/// Records all authentication attempts for compliance and security monitoring.
/// This is an append-only record - audit events should never be modified or deleted.
/// </summary>
public sealed record AuditEvent
{
    /// <summary>
    /// Unique identifier for the audit event record.
    /// </summary>
    public int Id { get; init; }

    /// <summary>
    /// Type of authentication event (e.g., "LOGIN_SUCCESS", "LOGIN_FAILURE").
    /// </summary>
    public required string EventType { get; init; }

    /// <summary>
    /// Authentication protocol used for this attempt.
    /// </summary>
    public required string Protocol { get; set; }

    /// <summary>
    /// User identifier if available. May be null for failed attempts where user was not found.
    /// </summary>
    public int? EmployeeId { get; init; }

    /// <summary>
    /// Username submitted in the authentication request. May be null for non-username protocols.
    /// </summary>
    public string? Username { get; init; }

    /// <summary>
    /// IP address of the client making the authentication request.
    /// </summary>
    public string? IpAddress { get; init; }

    /// <summary>
    /// Timestamp when the authentication event occurred.
    /// </summary>
    public DateTime? CreatedAt { get; set; }

    /// <summary>
    /// Reason for authentication failure. Null for successful authentications.
    /// </summary>
    public string? FailureReason { get; init; }
}