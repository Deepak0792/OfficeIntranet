namespace SdxCore.Employee.Application.DTOs.Request;
using System;

public class AddEmployeeTeamRequest
{
    public short TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
