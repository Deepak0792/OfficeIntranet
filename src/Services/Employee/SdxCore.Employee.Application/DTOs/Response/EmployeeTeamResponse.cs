namespace SdxCore.Employee.Application.DTOs.Response;
using System;

public class EmployeeTeamResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short TeamId { get; set; }
    public string? TeamName { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
