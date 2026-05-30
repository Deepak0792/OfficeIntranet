namespace SdxCore.Time.Application.DTOs.Response;

public class DocumentTypeResponse
{
    public short Id { get; set; }
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
    public bool IsActive { get; set; }
}

