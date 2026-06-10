namespace SdxCore.Employee.Application.DTOs.Response;
using System;

public class EmployeeSkillResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid SkillId { get; set; }
    public string? SkillName { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
    public bool IsActive { get; set; }
}
