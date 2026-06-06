using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeSkill : BaseAuditEntity<int>, IPublishableEntity
{
    public int EmployeeId { get; set; }
    public short SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;
    public Skill Skill { get; set; } = null!;
}
