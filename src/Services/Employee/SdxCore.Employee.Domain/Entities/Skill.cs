using System.Collections.Generic;

namespace SdxCore.Employee.Domain.Entities;

public class Skill : BaseEntity
{
    public short Id { get; set; }
    public string SkillName { get; set; } = string.Empty;
    public string? SkillCategory { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeSkill> EmployeeSkills { get; set; } = new List<EmployeeSkill>();
}
