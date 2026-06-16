using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class RotationShift : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string RotationCode { get; set; }
    public required string RotationName { get; set; }
    public short CycleLengthDays { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public ICollection<RotationShiftDetail> Details { get; set; } = [];
}
