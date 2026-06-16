using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Shift.Request;

namespace SdxCore.Attendance.Application.Validators.Shift;

public class CreateShiftRequestValidator : AbstractValidator<CreateShiftRequest>
{
    public CreateShiftRequestValidator()
    {
        RuleFor(x => x.ShiftCode).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ShiftName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.EndTime).NotEqual(x => x.StartTime).WithMessage("EndTime cannot equal StartTime.");
        RuleFor(x => x.BreakDurationMinutes).GreaterThanOrEqualTo((short)0);
        RuleFor(x => x.GraceInMinutes).GreaterThanOrEqualTo((short)0);
        RuleFor(x => x.GraceOutMinutes).GreaterThanOrEqualTo((short)0);
    }
}
