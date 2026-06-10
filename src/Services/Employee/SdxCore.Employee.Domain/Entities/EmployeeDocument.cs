using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDocument : BaseAuditEntity<Guid>
{
    public Guid EmployeeId { get; set; }
    public Guid DocumentTypeId { get; set; }
    public string? FileName { get; set; }
    public string? OriginalFileName { get; set; }
    public string? FileExtension { get; set; }
    public string? MimeType { get; set; }
    public int? FileSizeInBytes { get; set; }
    public string? FileUrl { get; set; }
    public string? DocumentNumber { get; set; }
    public DateOnly? IssuedDate { get; set; }
    public DateOnly? ExpiryDate { get; set; }
    public string? Remarks { get; set; }
    public DateTime UploadedAt { get; set; }
    public bool IsVerified { get; set; }
    public Guid? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public Guid? WorkflowInstanceId { get; set; }
    public bool IsActive { get; set; } = true;
}
