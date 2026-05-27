using System.Collections.Generic;

namespace SdxCore.Employee.Domain.Entities;

public class Team : BaseEntity
{
    public short Id { get; set; }
    public string TeamCode { get; set; } = string.Empty;
    public string TeamName { get; set; } = string.Empty;
    public string? TeamType { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeTeam> EmployeeTeams { get; set; } = new List<EmployeeTeam>();
}
