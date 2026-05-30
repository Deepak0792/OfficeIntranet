namespace SdxCore.Time.Application.DTOs.Response;

public class DesignationResponse
{
    public short Id { get; set; }
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
    public bool IsActive { get; set; }
}

