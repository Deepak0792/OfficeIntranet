namespace SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;
using System;

public class CreateEmployeeTeamRequest
{
    public Guid TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public bool IsPrimaryTeam { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
