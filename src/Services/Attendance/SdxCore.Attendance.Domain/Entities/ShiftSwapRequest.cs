using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// ShiftSwapStatusGroup is a computed/persisted column — never assigned by EF.
/// </summary>
public class ShiftSwapRequest : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid RequesterEmployeeId { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid TargetEmployeeId { get; set; }

    public Guid RequesterRosterId { get; set; }
    public Guid TargetRosterId { get; set; }
    public required string ShiftSwapStatus { get; set; }

    /// <summary>Computed persisted column — DO NOT ASSIGN. FK group for StatusLookup.</summary>
    public string ShiftSwapStatusGroup { get; set; } = string.Empty;

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    public DateTime RequestedAt { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }
    public string? Remarks { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigations
    public EmployeeShiftRoster RequesterRoster { get; set; } = null!;
    public EmployeeShiftRoster TargetRoster { get; set; } = null!;
}
