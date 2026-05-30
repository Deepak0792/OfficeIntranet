namespace SdxCore.Identity.Domain.DTOs.Response;
public class RefreshTokenResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string RawToken { get; set; } = default!;
    public string HashToken { get; set; } = default!;
    public DateTime ExpiresAt { get; set; }
}