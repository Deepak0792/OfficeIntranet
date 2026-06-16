using FluentValidation;
using SdxCore.Attendance.Application.DTOs.Roster.Request;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Validators.Roster;

public class GenerateRosterRequestValidator : AbstractValidator<GenerateRosterRequest>
{
    private static readonly string[] ValidTypes = [RosterGenerationType.Monthly, RosterGenerationType.Weekly, RosterGenerationType.Adhoc];

    public GenerateRosterRequestValidator()
    {
        RuleFor(x => x.FromDate).NotEmpty();
        RuleFor(x => x.ToDate).NotEmpty()
            .GreaterThanOrEqualTo(x => x.FromDate).WithMessage("ToDate must be on or after FromDate.");
        RuleFor(x => x.GenerationType).NotEmpty()
            .Must(t => ValidTypes.Contains(t)).WithMessage("GenerationType must be MONTHLY, WEEKLY, or ADHOC.");
    }
}

public class RosterUploadRequestValidator : AbstractValidator<RosterUploadRequest>
{
    public RosterUploadRequestValidator()
    {
        RuleFor(x => x.FromDate).NotEmpty();
        RuleFor(x => x.ToDate).NotEmpty()
            .GreaterThanOrEqualTo(x => x.FromDate).WithMessage("ToDate must be on or after FromDate.");
        RuleFor(x => x.Rows).NotEmpty().WithMessage("Rows cannot be empty.");
        RuleForEach(x => x.Rows).ChildRules(row =>
        {
            row.RuleFor(r => r.EmployeeId).NotEmpty();
            row.RuleFor(r => r.Date).NotEmpty();
        });
    }
}
