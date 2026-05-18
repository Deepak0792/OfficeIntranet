using Microsoft.EntityFrameworkCore;
using SdxCore.Shared.Domain.Entities;

namespace SdxCore.Shared.Persistence.Data;

public class SharedDbContext : DbContext
{
    public SharedDbContext(DbContextOptions<SharedDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // The shared.GetLookup SP returns this type, it's not a real table in EF
        modelBuilder.Entity<LookupItem>().HasNoKey();
    }
}
