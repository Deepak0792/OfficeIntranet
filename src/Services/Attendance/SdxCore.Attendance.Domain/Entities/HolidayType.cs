using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class HolidayType : BaseAuditEntity<Guid>
{
    public required string HolidayTypeCode { get; set; }
    public required string HolidayTypeName { get; set; }
    public bool IsOptional { get; set; }
    public bool IsActive { get; set; } = true;
}
