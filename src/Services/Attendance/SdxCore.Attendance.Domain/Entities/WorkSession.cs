using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class WorkSession : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public Guid? EmployeeShiftRosterId { get; set; }
    public DateOnly SessionDate { get; set; }
    public DateTime CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public int? WorkedMinutes { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? AutoCheckoutDueAt { get; set; }
    public bool AutoCheckoutProcessed { get; set; }
    public bool IsAutoCheckout { get; set; }
    // Intra-schema navigation
    public EmployeeShiftRoster? EmployeeShiftRoster { get; set; }
}
