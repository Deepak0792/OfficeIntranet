namespace SdxCore.Identity.Application.DTOs.User.Request;

/// <summary>
/// Represents a request to change a user's password in the InHouse provider.
/// </summary>
public sealed record DeactivateUserRequest
{
    public required Guid EmployeeId { get; set; }
}
