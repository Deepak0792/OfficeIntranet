using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class Holiday : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid HolidayCalendarId { get; set; }
    public Guid HolidayTypeId { get; set; }
    public required string HolidayCode { get; set; }
    public required string HolidayName { get; set; }
    public DateOnly HolidayDate { get; set; }
    public bool IsHalfDay { get; set; }
    public string? HalfDaySession { get; set; }

    /// <summary>When true, the year part of HolidayDate is ignored and the holiday recurs every year.</summary>
    public bool IsRecurring { get; set; }

    public short? ApplicableYear { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigations
    public HolidayCalendar HolidayCalendar { get; set; } = null!;
    public HolidayType HolidayType { get; set; } = null!;
}
