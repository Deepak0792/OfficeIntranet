using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeSkill : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; } = false;
    public DateTime? LastUsedDate { get; set; }

    public Employee? Employee { get; set; }
    public Skill? Skill { get; set; }
}
