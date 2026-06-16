using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Holiday.Request;

namespace SdxCore.Attendance.Application.Validators.Holiday;

public class CreateHolidayCalendarRequestValidator : AbstractValidator<CreateHolidayCalendarRequest>
{
    public CreateHolidayCalendarRequestValidator()
    {
        RuleFor(x => x.CalendarCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.CalendarName).NotEmpty().MaximumLength(200);
    }
}

public class CreateHolidayRequestValidator : AbstractValidator<CreateHolidayRequest>
{
    public CreateHolidayRequestValidator()
    {
        RuleFor(x => x.HolidayCalendarId).NotEmpty();
        RuleFor(x => x.HolidayTypeId).NotEmpty();
        RuleFor(x => x.HolidayCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.HolidayName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.HolidayDate).NotEmpty();
    }
}
