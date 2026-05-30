namespace SdxCore.Employee.Application.DTOs.Request;
using System;

public class UpdateEmployeeTeamRequest
{
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
