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

        modelBuilder.Entity<Domain.Entities.Employee>(entity =>
        {
            entity.ToTable("Employee");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.Property(e => e.EmployeeCode).HasMaxLength(50).IsRequired();
        });

        modelBuilder.Entity<EmployeeSummary>(entity =>
        {
            entity.ToView("vwEmployeeSummary");
            entity.HasNoKey();
        });

        modelBuilder.Entity<EmployeeSkill>(entity =>
        {
            entity.ToTable("EmployeeSkill");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne(d => d.Employee).WithMany().HasForeignKey(d => d.EmployeeId);
            entity.HasOne(d => d.Skill).WithMany(p => p.EmployeeSkills).HasForeignKey(d => d.SkillId);
        });

        modelBuilder.Entity<Team>(entity =>
        {
            entity.ToTable("Team");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
        });

        modelBuilder.Entity<EmployeeTeam>(entity =>
        {
            entity.ToTable("EmployeeTeam");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne(d => d.Employee).WithMany().HasForeignKey(d => d.EmployeeId);
            entity.HasOne(d => d.Team).WithMany(p => p.EmployeeTeams).HasForeignKey(d => d.TeamId);
        });

        modelBuilder.Entity<EmployeeBiometricMapping>(entity =>
        {
            entity.ToTable("EmployeeBiometricMapping");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeLegalEntity>(entity =>
        {
            entity.ToTable("EmployeeLegalEntity");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeDepartment>(entity =>
        {
            entity.ToTable("EmployeeDepartment");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeLocation>(entity =>
        {
            entity.ToTable("EmployeeLocation");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeRelationship>(entity =>
        {
            entity.ToTable("EmployeeRelationship");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.ParentEmployeeId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.ChildEmployeeId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<EmployeeContact>(entity =>
        {
            entity.ToTable("EmployeeContact");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeDocument>(entity =>
        {
            entity.ToTable("EmployeeDocument");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeAddress>(entity =>
        {
            entity.ToTable("EmployeeAddress");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<OutboxMessage>(entity =>
        {
            entity.ToTable("OutboxMessages", "employee");
            entity.HasKey(e => e.Id);
            entity.Property(x => x.Id).ValueGeneratedNever();
        });
    }
}
