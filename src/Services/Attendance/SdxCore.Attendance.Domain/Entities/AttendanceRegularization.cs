using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// RegularizationStatusGroup is a computed/persisted column — never assigned by EF.
/// </summary>
public class AttendanceRegularization : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public DateOnly AttendanceDate { get; set; }
    public DateTime? RequestedCheckIn { get; set; }
    public DateTime? RequestedCheckOut { get; set; }
    public string? Reason { get; set; }
    public required string RegularizationStatus { get; set; }

    /// <summary>Computed persisted column — DO NOT ASSIGN. FK group for StatusLookup.</summary>
    public string RegularizationStatusGroup { get; set; } = string.Empty;

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }
    public string? Remarks { get; set; }
    public bool IsActive { get; set; } = true;
}
