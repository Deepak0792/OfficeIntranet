namespace SdxCore.Employee.Application.DTOs.EmployeeSkill.Request;
using System;

public class CreateEmployeeSkillRequest
{
    public Guid SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
}
