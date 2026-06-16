using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class HolidayCalendar : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string CalendarCode { get; set; }
    public required string CalendarName { get; set; }
    public string? Description { get; set; }
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; } = true;
}
