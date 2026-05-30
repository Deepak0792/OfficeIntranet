namespace SdxCore.Employee.Domain.Entities;
using System;

public class EmployeeSkill : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }

    public Employee Employee { get; set; } = null!;
    public Skill Skill { get; set; } = null!;
}
