using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// ClosingBalance is a non-stored computed column — never assigned by EF.
/// UNIQUE: (EmployeeId, LeaveTypeId, BalanceYear)
/// </summary>
public class LeaveBalance : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public Guid LeaveTypeId { get; set; }
    public short BalanceYear { get; set; }
    public decimal OpeningBalance { get; set; }
    public decimal Allocated { get; set; }
    public decimal Availed { get; set; }
    public decimal Encashed { get; set; }
    public decimal CarryForward { get; set; }

    /// <summary>Computed column: (OpeningBalance + Allocated + CarryForward - Availed - Encashed) — DO NOT ASSIGN.</summary>
    public decimal ClosingBalance { get; set; }

    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public LeaveType LeaveType { get; set; } = null!;
}
