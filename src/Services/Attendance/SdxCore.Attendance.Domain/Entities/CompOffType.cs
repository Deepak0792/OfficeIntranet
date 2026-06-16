using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class CompOffType : BaseAuditEntity<Guid>
{
    public required string CompOffTypeCode { get; set; }
    public required string CompOffTypeName { get; set; }
    public short? ExpiryDays { get; set; }
    public bool IsActive { get; set; } = true;
}
