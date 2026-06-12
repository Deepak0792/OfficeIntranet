using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDocument : BaseAuditEntity<Guid>
{
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.DocumentType — stored as ID only, no nav prop.</summary>
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
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public bool IsVerified { get; set; }

    /// <summary>Intra-schema FK to employee.Employee — the employee who verified this document.</summary>
    public Guid? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — stored as ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>The employee who owns this document.</summary>
    public Employee Employee { get; set; } = null!;

    /// <summary>The employee who verified this document (optional, same schema).</summary>
    public Employee? VerifierEmployee { get; set; }
}
