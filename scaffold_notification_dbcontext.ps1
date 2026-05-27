$dataDir = "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.Persistence\Data"
$configDir = "$dataDir\Configurations"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$dbContextCode = @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Notification.Domain.Entities;

namespace SdxCore.Notification.Persistence.Data;

public class NotificationDbContext : DbContext
{
    public NotificationDbContext(DbContextOptions<NotificationDbContext> options) : base(options) { }

    public DbSet<NotificationTemplate> NotificationTemplates => Set<NotificationTemplate>();
    public DbSet<NotificationLog> NotificationLogs => Set<NotificationLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("notification");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(NotificationDbContext).Assembly);
    }
}
"@
Set-Content -Path "$dataDir\NotificationDbContext.cs" -Value $dbContextCode

$logConfig = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Notification.Domain.Entities;

namespace SdxCore.Notification.Persistence.Data.Configurations;

public class NotificationLogConfiguration : IEntityTypeConfiguration<NotificationLog>
{
    public void Configure(EntityTypeBuilder<NotificationLog> builder)
    {
        builder.ToTable("NotificationLog");
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.RecipientAddress).HasMaxLength(200);
        builder.Property(e => e.Channel).HasMaxLength(50);
        builder.Property(e => e.Subject).HasMaxLength(500);
        builder.Property(e => e.Status).HasMaxLength(50);
    }
}
"@
Set-Content -Path "$configDir\NotificationLogConfiguration.cs" -Value $logConfig

Write-Output "Successfully generated Notification DbContext and Configurations."
