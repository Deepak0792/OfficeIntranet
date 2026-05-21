namespace SdxCore.Time.Domain.DTOs;

public class DocumentTypeDto
{
    public short Id { get; set; }
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
    public bool IsActive { get; set; }
}

public class CreateDocumentTypeDto
{
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
}

public class UpdateDocumentTypeDto : CreateDocumentTypeDto { }
