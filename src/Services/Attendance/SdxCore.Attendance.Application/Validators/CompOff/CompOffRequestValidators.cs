using FluentValidation;
using SdxCore.Attendance.Application.DTOs.CompOff.Request;

namespace SdxCore.Attendance.Application.Validators.CompOff;

public class EarnCompOffRequestValidator : AbstractValidator<EarnCompOffRequest>
{
    public EarnCompOffRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.CompOffTypeId).NotEmpty();
        RuleFor(x => x.EarnedDate).NotEmpty();
        RuleFor(x => x.TotalDays).GreaterThan(0);
    }
}

public class RedeemCompOffRequestValidator : AbstractValidator<RedeemCompOffRequest>
{
    public RedeemCompOffRequestValidator()
    {
        RuleFor(x => x.EmployeeId).NotEmpty();
        RuleFor(x => x.CompOffBalanceId).NotEmpty();
        RuleFor(x => x.RequestedDays).GreaterThan(0);
    }
}
