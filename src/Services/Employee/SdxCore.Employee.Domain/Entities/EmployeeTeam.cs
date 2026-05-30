namespace SdxCore.Employee.Domain.Entities;
using System;

public class EmployeeTeam : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }

    public Employee Employee { get; set; } = null!;
    public Team Team { get; set; } = null!;
}
