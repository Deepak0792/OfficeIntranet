using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Ordered segment within a rotation cycle.
/// CHECK constraint: (IsOffDay=1 AND ShiftId IS NULL) OR (IsOffDay=0 AND ShiftId IS NOT NULL)
/// UNIQUE: (RotationShiftId, SequenceNo)
/// </summary>
public class RotationShiftDetail : BaseAuditEntity<Guid>
{
    public Guid RotationShiftId { get; set; }

    /// <summary>Nullable — null when IsOffDay=true.</summary>
    public Guid? ShiftId { get; set; }

    public short SequenceNo { get; set; }
    public short DurationDays { get; set; }
    public bool IsOffDay { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigations
    public RotationShift RotationShift { get; set; } = null!;
    public Shift? Shift { get; set; }
}
