namespace SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;

public class UpdateEmployeeTeamRequest
{
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public bool IsPrimaryTeam { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
