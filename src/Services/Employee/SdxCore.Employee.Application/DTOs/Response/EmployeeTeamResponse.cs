namespace SdxCore.Employee.Application.DTOs.Response;
using System;

public class EmployeeTeamResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid TeamId { get; set; }
    public string? TeamName { get; set; }
    public string? RoleInTeam { get; set; }
    public bool IsPrimaryTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
