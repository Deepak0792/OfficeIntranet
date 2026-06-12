namespace SdxCore.Time.Application.DTOs.DocumentType.Response;

public class DocumentTypeResponse
{
    public Guid Id { get; set; }
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
    public bool IsActive { get; set; }
}

