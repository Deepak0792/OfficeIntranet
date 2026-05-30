namespace SdxCore.Employee.Application.DTOs.Request;
using System;

public class AddEmployeeSkillRequest
{
    public short SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
}
