using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class Team : BaseAuditEntity<short>, IPublishableEntity
{
    public required string TeamCode { get; set; }
    public required string TeamName { get; set; }
    public string? TeamType { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
    public ICollection<EmployeeTeam> EmployeeTeams { get; set; } = new List<EmployeeTeam>();
}
