namespace SdxCore.Identity.Application.DTOs.Token.Response;
public class RefreshTokenResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public string RawToken { get; set; } = default!;
    public string HashToken { get; set; } = default!;
    public DateTime ExpiresAt { get; set; }
}