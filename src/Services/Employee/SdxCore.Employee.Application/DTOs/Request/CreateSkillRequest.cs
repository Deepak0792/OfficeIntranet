namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateSkillRequest
{
    public required string SkillName { get; set; }
    public string? SkillCategory { get; set; }
    public string? Description { get; set; }
}
