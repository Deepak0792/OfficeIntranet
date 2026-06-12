namespace SdxCore.Employee.Application.DTOs.EmployeeSkill.Request;

public class UpdateEmployeeSkillRequest
{
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; }
    public DateOnly? LastUsedDate { get; set; }
}
