using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// UNIQUE: (WorkWeekPolicyId, DayOfWeek)
/// </summary>
public class WorkWeekPolicyDay : BaseAuditEntity<Guid>
{
    public Guid WorkWeekPolicyId { get; set; }

    /// <summary>0 = Sunday … 6 = Saturday</summary>
    public byte DayOfWeek { get; set; }

    public bool IsWorkingDay { get; set; }
    public short? StandardWorkingMinutes { get; set; }
    public bool IsHalfDay { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public WorkWeekPolicy WorkWeekPolicy { get; set; } = null!;
}
