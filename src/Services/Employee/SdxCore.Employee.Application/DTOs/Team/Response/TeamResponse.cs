namespace SdxCore.Employee.Application.DTOs.Team.Response;
using System;

public class TeamResponse
{
    public Guid Id { get; set; }
    public required string TeamCode { get; set; }
    public required string TeamName { get; set; }
    public string? TeamType { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
