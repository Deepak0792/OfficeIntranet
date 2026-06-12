namespace SdxCore.Time.Application.DTOs.DocumentType.Request;

public class CreateDocumentTypeRequest
{
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
}

