using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// LeaveStatusGroup is a computed/persisted column — never assigned by EF.
/// </summary>
public class LeaveRequest : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public Guid LeaveTypeId { get; set; }
    public required string LeaveStatus { get; set; }

    /// <summary>Computed persisted column — DO NOT ASSIGN. FK group for StatusLookup.</summary>
    public string LeaveStatusGroup { get; set; } = string.Empty;

    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
    public decimal TotalDays { get; set; }
    public bool IsHalfDay { get; set; }
    public string? HalfDaySession { get; set; }
    public string? Reason { get; set; }

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    public string? Remarks { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public LeaveType LeaveType { get; set; } = null!;
}
