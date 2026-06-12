namespace SdxCore.Time.Application.DTOs.Designation.Response;

public class DesignationResponse
{
    public Guid Id { get; set; }
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
    public bool IsActive { get; set; }
}

