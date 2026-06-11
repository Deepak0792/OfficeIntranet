using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeTeam : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }
    public Guid TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsPrimaryTeam { get; set; } = false;
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;to hav
    public Team Team { get; set; } = null!;
}
