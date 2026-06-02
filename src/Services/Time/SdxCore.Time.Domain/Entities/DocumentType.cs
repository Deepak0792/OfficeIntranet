using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class DocumentType : BaseAuditEntity<short>
{
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
}
