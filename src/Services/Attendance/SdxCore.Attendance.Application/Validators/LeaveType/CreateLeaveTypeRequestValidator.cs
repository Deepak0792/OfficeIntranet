using FluentValidation;
using SdxCore.Attendance.Application.DTOs.LeaveType.Request;

namespace SdxCore.Attendance.Application.Validators.LeaveType;

public class CreateLeaveTypeRequestValidator : AbstractValidator<CreateLeaveTypeRequest>
{
    public CreateLeaveTypeRequestValidator()
    {
        RuleFor(x => x.LeaveCode).NotEmpty().MaximumLength(50);
        RuleFor(x => x.LeaveName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.WorkflowCode).MaximumLength(200);
        RuleFor(x => x.MaxDaysPerYear).GreaterThan(0).When(x => x.MaxDaysPerYear.HasValue);
    }
}
