using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Persistence.Data;

public class EmployeeDbContext : DbContext
{
    public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options) : base(options) { }

    public DbSet<Domain.Entities.Employee> Employees => Set<Domain.Entities.Employee>();
    public DbSet<EmployeeDocument> EmployeeDocuments => Set<EmployeeDocument>();
    public DbSet<EmployeeAddress> EmployeeAddresses => Set<EmployeeAddress>();
    public DbSet<Skill> Skills => Set<Skill>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("employee");
    }
}
