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
