namespace SdxCore.Employee.Domain.Entities;
using System.Collections.Generic;

public class Team : BaseEntity
{
    public short Id { get; set; }
    public required string TeamCode { get; set; }
    public required string TeamName { get; set; }
    public string? TeamType { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeTeam> EmployeeTeams { get; set; } = new List<EmployeeTeam>();
}
