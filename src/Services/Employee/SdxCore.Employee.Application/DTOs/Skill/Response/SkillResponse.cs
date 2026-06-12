namespace SdxCore.Employee.Application.DTOs.Skill.Response;
using System;

public class SkillResponse
{
    public Guid Id { get; set; }
    public required string SkillName { get; set; }
    public string? SkillCategory { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
