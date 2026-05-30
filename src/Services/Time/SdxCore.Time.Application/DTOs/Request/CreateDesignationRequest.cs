namespace SdxCore.Time.Application.DTOs.Request;

public class CreateDesignationRequest
{
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
}

