namespace SdxCore.Common.Models;

/// <summary>
/// Standard error response model for failed requests across all microservices.
/// </summary>
public sealed record ErrorResponse
{
    /// <summary>
    /// Machine-readable error code.
    /// </summary>
    public required string ErrorCode { get; init; }

    /// <summary>
    /// Human-readable error message.
    /// </summary>
    public required string ErrorMessage { get; init; }

    /// <summary>
    /// Optional timestamp when the error occurred.
    /// </summary>
    public DateTimeOffset? Timestamp { get; init; }

    /// <summary>
    /// Optional additional error details or context.
    /// </summary>
    public object? Details { get; init; }
}