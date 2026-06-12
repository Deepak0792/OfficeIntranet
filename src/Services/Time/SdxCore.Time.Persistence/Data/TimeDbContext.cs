using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Data;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Persistence.Data;

public class TimeDbContext : SdxDbContext
{
    public TimeDbContext(DbContextOptions<TimeDbContext> options)
        : base(options)
    {
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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasDefaultSchema("time");

        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(TimeDbContext).Assembly);
    }
}