using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeSkill : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }
    public Guid SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;
    public Skill Skill { get; set; } = null!;
}
