using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class CompOffAvailment : BaseAuditEntity<Guid>
{
    public Guid LeaveRequestId { get; set; }

    public Guid CompOffBalanceId { get; set; }

    public decimal DaysAvailed { get; set; }

    public bool IsActive { get; set; }
    // Navigation Properties

    public LeaveRequest LeaveRequest { get; set; } = null!;

    public CompOffBalance CompOffBalance { get; set; } = null!;
}