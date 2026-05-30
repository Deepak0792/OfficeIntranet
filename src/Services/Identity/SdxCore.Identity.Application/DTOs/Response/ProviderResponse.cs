using System.Security.Claims;

namespace SdxCore.Identity.Domain.DTOs.Response;

/// <summary>
/// Represents the result returned by an authentication provider after processing credentials.
/// </summary>
public sealed record ProviderResponse
{
    /// <summary>
    /// Indicates whether the provider successfully authenticated the user.
    /// </summary>
    public required bool IsSuccess { get; init; }

    /// <summary>
    /// User claims extracted from the authentication source.
    /// </summary>
    public IReadOnlyList<Claim> Claims { get; init; } = [];

    /// <summary>
    /// Reason for authentication failure. Null when IsSuccess is true.
    /// </summary>
    public string? FailureReason { get; init; }
}
