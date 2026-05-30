namespace SdxCore.Employee.Application.DTOs.Request;
using System;

public class UpdateEmployeeSkillRequest
{
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public DateOnly? LastUsedDate { get; set; }
}
