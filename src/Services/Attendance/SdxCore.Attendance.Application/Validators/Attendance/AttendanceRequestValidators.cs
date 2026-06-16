using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Attendance.Request;

namespace SdxCore.Attendance.Application.Validators.Attendance;

public class CheckInRequestValidator : AbstractValidator<CheckInRequest>
{
    public CheckInRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.CheckInTime).NotEmpty();
    }
}

public class CheckOutRequestValidator : AbstractValidator<CheckOutRequest>
{
    public CheckOutRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.CheckOutTime).NotEmpty();
    }
}

public class CreateRegularizationRequestValidator : AbstractValidator<CreateRegularizationRequest>
{
    public CreateRegularizationRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.AttendanceDate).NotEmpty();
        RuleFor(x => x).Must(r => r.RequestedCheckIn.HasValue || r.RequestedCheckOut.HasValue)
            .WithMessage("At least one of RequestedCheckIn or RequestedCheckOut is required.");
        RuleFor(x => x.Reason).MaximumLength(1000);
    }
}
