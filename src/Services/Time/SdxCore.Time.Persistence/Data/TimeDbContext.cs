using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using SdxCore.SharedKernel.Entities;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Persistence.Data;

public class TimeDbContext : DbContext
{
    private readonly HashSet<string> _publishableEntities;

    public TimeDbContext(DbContextOptions<TimeDbContext> options, IConfiguration configuration) : base(options) 
    { 
        var configuredEntities = configuration.GetSection("OutboxSettings:PublishableEntities").Get<string[]>() ?? Array.Empty<string>();
        _publishableEntities = new HashSet<string>(configuredEntities, StringComparer.OrdinalIgnoreCase);
    }

    public DbSet<TimeZoneMaster> TimeZoneMasters => Set<TimeZoneMaster>();
    public DbSet<Country> Countries => Set<Country>();
    public DbSet<Region> Regions => Set<Region>();
    public DbSet<LegalEntity> LegalEntities => Set<LegalEntity>();
    public DbSet<OfficeLocation> OfficeLocations => Set<OfficeLocation>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<ScopeType> ScopeTypes => Set<ScopeType>();
    public DbSet<Designation> Designations => Set<Designation>();
    public DbSet<DocumentType> DocumentTypes => Set<DocumentType>();
    public DbSet<GeoFence> GeoFences => Set<GeoFence>();
    public DbSet<BiometricDevice> BiometricDevices => Set<BiometricDevice>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var entries = ChangeTracker.Entries<BaseEntity>()
            .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified || e.State == EntityState.Deleted)
            .Where(e => _publishableEntities.Contains(e.Entity.GetType().Name))
            .ToList();

        foreach (var entry in entries)
        {
            var entityName = entry.Entity.GetType().Name;
            
            // Detect Soft Delete vs Update
            var action = entry.State switch
            {
                EntityState.Added => "Created",
                EntityState.Modified => !entry.Entity.IsActive ? "SoftDeleted" : "Updated",
                EntityState.Deleted => "Deleted",
                _ => "Unknown"
            };

            var eventType = $"{entityName}{action}";
            var payload = JsonSerializer.Serialize((object)entry.Entity);
            var routingKey = $"cache.time.invalidate";

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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("time");
        
        // Outbox configuration
        modelBuilder.Entity<OutboxMessage>(b =>
        {
            b.ToTable("OutboxMessages", "time");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        });

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(TimeDbContext).Assembly);
    }
}
