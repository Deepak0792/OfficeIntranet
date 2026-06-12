using Microsoft.EntityFrameworkCore;
using SdxCore.Employee.Domain.Entities;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Data;

namespace SdxCore.Employee.Persistence.Data;

public class EmployeeDbContext : SdxDbContext
{
    public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options)
        : base(options)
    {
    }

    public DbSet<Domain.Entities.Employee> Employees { get; set; } = null!;
    public DbSet<EmployeeSummary> EmployeeFullProfiles { get; set; } = null!;
    public DbSet<OutboxMessage> OutboxMessages { get; set; } = null!;
    public DbSet<Skill> Skills { get; set; } = null!;
    public DbSet<EmployeeSkill> EmployeeSkills { get; set; } = null!;
    public DbSet<Team> Teams { get; set; } = null!;
    public DbSet<EmployeeTeam> EmployeeTeams { get; set; } = null!;
    public DbSet<EmployeeBiometricMapping> BiometricMappings { get; set; } = null!;
    public DbSet<EmployeeLegalEntity> EmployeeLegalEntities { get; set; } = null!;
    public DbSet<EmployeeDepartment> EmployeeDepartments { get; set; } = null!;
    public DbSet<EmployeeLocation> EmployeeLocations { get; set; } = null!;
    public DbSet<EmployeeRelationship> EmployeeRelationships { get; set; } = null!;
    public DbSet<EmployeeContact> EmployeeContacts { get; set; } = null!;
    public DbSet<EmployeeDocument> EmployeeDocuments { get; set; } = null!;
    public DbSet<EmployeeAddress> EmployeeAddresses { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasDefaultSchema("employee");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(EmployeeDbContext).Assembly);
    }
}
