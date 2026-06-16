using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Leave.Request;

namespace SdxCore.Attendance.Application.Validators.Leave;

public class CreateLeaveRequestRequestValidator : AbstractValidator<CreateLeaveRequestRequest>
{
    public CreateLeaveRequestRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.LeaveTypeId).NotEmpty();
        RuleFor(x => x.FromDate).NotEmpty();
        RuleFor(x => x.ToDate).NotEmpty()
            .GreaterThanOrEqualTo(x => x.FromDate).WithMessage("ToDate must be on or after FromDate.");
        RuleFor(x => x.Reason).MaximumLength(1000);
        RuleFor(x => x.HalfDaySession).MaximumLength(20).When(x => x.IsHalfDay);
    }
}
