using FluentValidation;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Request;

namespace SdxCore.Attendance.Application.Validators.ShiftSwap;

public class CreateShiftSwapRequestValidator : AbstractValidator<CreateShiftSwapRequest>
{
    public CreateShiftSwapRequestValidator()
    {
        RuleFor(x => x.RequesterEmployeeId).NotEmpty();
        RuleFor(x => x.TargetEmployeeId).NotEmpty();
        RuleFor(x => x.RequesterRosterId).NotEmpty();
        RuleFor(x => x.TargetRosterId).NotEmpty();
        RuleFor(x => x.TargetEmployeeId)
            .NotEqual(x => x.RequesterEmployeeId).WithMessage("Requester and Target employees must be different.");
    }
}
