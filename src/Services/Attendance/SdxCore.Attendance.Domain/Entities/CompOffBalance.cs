using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// RemainingDays is a non-stored computed column — never assigned by EF.
/// </summary>
public class CompOffBalance : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public Guid CompOffTypeId { get; set; }
    public DateOnly EarnedDate { get; set; }
    public DateOnly? ExpiryDate { get; set; }
    public decimal TotalDays { get; set; }
    public decimal AvailedDays { get; set; }

    /// <summary>Computed column: (TotalDays - AvailedDays) — DO NOT ASSIGN.</summary>
    public decimal RemainingDays { get; set; }

    public Guid? AttendanceRecordId { get; set; }

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    public bool IsActive { get; set; } = true;

    // Intra-schema navigations
    public CompOffType CompOffType { get; set; } = null!;
    public AttendanceRecord? AttendanceRecord { get; set; }
}
