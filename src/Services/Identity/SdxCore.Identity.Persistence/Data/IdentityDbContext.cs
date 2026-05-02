using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Persistence.Configurations;

namespace SdxCore.Identity.Persistence.Data;

/// <summary>
/// Entity Framework Core database context for the Identity service.
/// Manages User and AuditEvent entities with SQL Server.
/// </summary>
public class IdentityDbContext : DbContext
{
    /// <summary>
    /// Initializes a new instance of the <see cref="IdentityDbContext"/> class.
    /// </summary>
    /// <param name="options">The options to be used by the DbContext.</param>
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options)
        : base(options)
    {
    }

    /// <summary>
    /// Gets or sets the DbSet for User entities.
    /// </summary>
    public DbSet<User> Users => Set<User>();

    /// <summary>
    /// Gets or sets the DbSet for AuditEvent entities.
    /// </summary>
    public DbSet<AuditEvent> AuditEvents => Set<AuditEvent>();

    /// <summary>
    /// Configures the entity mappings using Fluent API.
    /// </summary>
    /// <param name="modelBuilder">The builder being used to construct the model for this context.</param>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply entity configurations
        modelBuilder.ApplyConfiguration(new UserConfiguration());
        modelBuilder.ApplyConfiguration(new AuditEventConfiguration());
    }
}
