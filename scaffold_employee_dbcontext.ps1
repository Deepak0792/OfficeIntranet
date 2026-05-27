$dataDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Persistence\Data"
$configDir = "$dataDir\Configurations"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$dbContextCode = @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Persistence.Data;

public class EmployeeDbContext : DbContext
{
    public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options) : base(options) { }

    public DbSet<SdxCore.Employee.Domain.Entities.Employee> Employees => Set<SdxCore.Employee.Domain.Entities.Employee>();
    public DbSet<EmployeeLegalEntity> EmployeeLegalEntities => Set<EmployeeLegalEntity>();
    public DbSet<EmployeeDepartment> EmployeeDepartments => Set<EmployeeDepartment>();
    public DbSet<EmployeeLocation> EmployeeLocations => Set<EmployeeLocation>();
    public DbSet<EmployeeRelationship> EmployeeRelationships => Set<EmployeeRelationship>();
    public DbSet<EmployeeContact> EmployeeContacts => Set<EmployeeContact>();
    public DbSet<EmployeeDocument> EmployeeDocuments => Set<EmployeeDocument>();
    public DbSet<Skill> Skills => Set<Skill>();
    public DbSet<EmployeeSkill> EmployeeSkills => Set<EmployeeSkill>();
    public DbSet<Team> Teams => Set<Team>();
    public DbSet<EmployeeTeam> EmployeeTeams => Set<EmployeeTeam>();
    public DbSet<BiometricEmployeeMapping> BiometricEmployeeMappings => Set<BiometricEmployeeMapping>();
    public DbSet<EmployeeAddress> EmployeeAddresses => Set<EmployeeAddress>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("employee");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(EmployeeDbContext).Assembly);
    }
}
"@
Set-Content -Path "$dataDir\EmployeeDbContext.cs" -Value $dbContextCode

$employeeConfig = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace SdxCore.Employee.Persistence.Data.Configurations;

public class EmployeeConfiguration : IEntityTypeConfiguration<Domain.Entities.Employee>
{
    public void Configure(EntityTypeBuilder<Domain.Entities.Employee> builder)
    {
        builder.ToTable("Employee");
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.EmployeeCode).IsRequired().HasMaxLength(50);
        builder.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
        builder.Property(e => e.LastName).HasMaxLength(100);
        builder.Property(e => e.DisplayName).HasMaxLength(200);
        builder.Property(e => e.Email).IsRequired().HasMaxLength(255);
        builder.Property(e => e.MobileNumber).HasMaxLength(30);
        builder.Property(e => e.PreferredLanguage).HasMaxLength(20);
        builder.Property(e => e.EmploymentType).IsRequired().HasMaxLength(50).HasDefaultValue("FULL_TIME");
        builder.Property(e => e.AboutMe);
        builder.Property(e => e.ProfilePhotoUrl).HasMaxLength(1000);
        
        builder.HasIndex(e => e.EmployeeCode).IsUnique();
        builder.HasIndex(e => e.Email).IsUnique();
    }
}
"@
Set-Content -Path "$configDir\EmployeeConfiguration.cs" -Value $employeeConfig

Write-Output "Successfully generated Employee DbContext and Configurations."
