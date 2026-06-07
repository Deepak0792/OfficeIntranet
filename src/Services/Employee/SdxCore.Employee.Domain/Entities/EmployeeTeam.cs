using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeTeam : BaseAuditEntity<int>, IPublishableEntity
{
    public int EmployeeId { get; set; }
    public short TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsPrimaryTeam { get; set; } = false;
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;
    public Team Team { get; set; } = null!;
}
