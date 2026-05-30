using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using SdxCore.Employee.Domain.Entities;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Persistence.Data;

public class EmployeeDbContext : DbContext
{
    private readonly HashSet<string> _publishableEntities;

    public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options, IConfiguration configuration) : base(options)
    {
        var configuredEntities = configuration.GetSection("OutboxSettings:PublishableEntities").Get<string[]>() ?? Array.Empty<string>();
        _publishableEntities = new HashSet<string>(configuredEntities, StringComparer.OrdinalIgnoreCase);
    }

    public DbSet<Domain.Entities.Employee> Employees { get; set; } = null!;
    public DbSet<EmployeeFullProfile> EmployeeFullProfiles { get; set; } = null!;
    public DbSet<OutboxMessage> OutboxMessages { get; set; } = null!;
    public DbSet<Skill> Skills { get; set; } = null!;
    public DbSet<EmployeeSkill> EmployeeSkills { get; set; } = null!;
    public DbSet<Team> Teams { get; set; } = null!;
    public DbSet<EmployeeTeam> EmployeeTeams { get; set; } = null!;
    public DbSet<BiometricEmployeeMapping> BiometricMappings { get; set; } = null!;
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
            entity.Property(e => e.EmployeeCode).HasMaxLength(50).IsRequired();
        });

        modelBuilder.Entity<EmployeeFullProfile>(entity =>
        {
            entity.ToView("vw_EmployeeFullProfile");
            entity.HasNoKey();
        });

        modelBuilder.Entity<Skill>(entity =>
        {
            entity.ToTable("Skill");
            entity.HasKey(e => e.Id);
        });

        modelBuilder.Entity<EmployeeSkill>(entity =>
        {
            entity.ToTable("EmployeeSkill");
            entity.HasKey(e => e.Id);
            entity.HasOne(d => d.Employee).WithMany().HasForeignKey(d => d.EmployeeId);
            entity.HasOne(d => d.Skill).WithMany(p => p.EmployeeSkills).HasForeignKey(d => d.SkillId);
        });

        modelBuilder.Entity<Team>(entity =>
        {
            entity.ToTable("Team");
            entity.HasKey(e => e.Id);
        });

        modelBuilder.Entity<EmployeeTeam>(entity =>
        {
            entity.ToTable("EmployeeTeam");
            entity.HasKey(e => e.Id);
            entity.HasOne(d => d.Employee).WithMany().HasForeignKey(d => d.EmployeeId);
            entity.HasOne(d => d.Team).WithMany(p => p.EmployeeTeams).HasForeignKey(d => d.TeamId);
        });

        modelBuilder.Entity<BiometricEmployeeMapping>(entity =>
        {
            entity.ToTable("BiometricEmployeeMapping");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeLegalEntity>(entity =>
        {
            entity.ToTable("EmployeeLegalEntity");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeDepartment>(entity =>
        {
            entity.ToTable("EmployeeDepartment");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeLocation>(entity =>
        {
            entity.ToTable("EmployeeLocation");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeRelationship>(entity =>
        {
            entity.ToTable("EmployeeRelationship");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.ParentEmployeeId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.ChildEmployeeId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<EmployeeContact>(entity =>
        {
            entity.ToTable("EmployeeContact");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeDocument>(entity =>
        {
            entity.ToTable("EmployeeDocument");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<EmployeeAddress>(entity =>
        {
            entity.ToTable("EmployeeAddress");
            entity.HasKey(e => e.Id);
            entity.HasOne<Domain.Entities.Employee>().WithMany().HasForeignKey(d => d.EmployeeId);
        });

        modelBuilder.Entity<OutboxMessage>(entity =>
        {
            entity.ToTable("OutboxMessages", "employee");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        });
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var entries = ChangeTracker.Entries<BaseEntity>()
            .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified || e.State == EntityState.Deleted)
            .Where(e => _publishableEntities.Contains(e.Entity.GetType().Name))
            .ToList();

        foreach (var entry in entries)
        {
            var entityName = entry.Entity.GetType().Name;
            
            var action = entry.State switch
            {
                EntityState.Added => "Created",
                EntityState.Modified => !entry.Entity.IsActive ? "SoftDeleted" : "Updated",
                EntityState.Deleted => "Deleted",
                _ => "Unknown"
            };

            var eventType = $"{entityName}{action}";
            var payload = JsonSerializer.Serialize((object)entry.Entity);
            var routingKey = $"cache.employee.invalidate";

            var outboxMessage = new OutboxMessage
            {
                EventType = eventType,
                Payload = payload,
                Exchange = "sdxcore.events",
                RoutingKey = routingKey,
                Status = "PENDING",
                StatusGroup = "OUTBOX_STATUS"
            };

            OutboxMessages.Add(outboxMessage);
        }

        return await base.SaveChangesAsync(cancellationToken);
    }
}
