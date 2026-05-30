namespace SdxCore.Employee.Domain.Entities;
using System.Collections.Generic;

public class Skill : BaseEntity
{
    public short Id { get; set; }
    public required string SkillName { get; set; }
    public string? SkillCategory { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeSkill> EmployeeSkills { get; set; } = new List<EmployeeSkill>();
}
