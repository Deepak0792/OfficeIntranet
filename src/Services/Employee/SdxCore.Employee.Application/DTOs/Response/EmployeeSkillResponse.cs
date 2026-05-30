namespace SdxCore.Employee.Application.DTOs.Response;
using System;

public class EmployeeSkillResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short SkillId { get; set; }
    public string? SkillName { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
    public bool IsActive { get; set; }
}
