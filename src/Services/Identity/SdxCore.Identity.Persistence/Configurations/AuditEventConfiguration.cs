using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;

namespace SdxCore.Identity.Persistence.Configurations;

/// <summary>
/// Entity Framework Core configuration for the AuditEvent entity.
/// Defines table schema, indexes, constraints, and column types using Fluent API.
/// AuditEvent is an append-only table for compliance - no updates or deletes allowed.
/// </summary>
public class AuditEventConfiguration : IEntityTypeConfiguration<AuditEvent>
{
    /// <summary>
    /// Configures the AuditEvent entity.
    /// </summary>
    /// <param name="builder">The builder to be used to configure the entity type.</param>
    public void Configure(EntityTypeBuilder<AuditEvent> builder)
    {
        // Table name
        builder.ToTable("AuditEvents");

        // Since AuditEvent is a record type without an explicit Id property,
        // we need to configure a shadow property as the primary key
        builder.Property<int>("Id")
            .ValueGeneratedOnAdd();
        
        builder.HasKey("Id");

        // Properties
        builder.Property(a => a.EventType)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(a => a.Protocol)
            .IsRequired()
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(a => a.EmployeeId)
            .IsRequired(false)
            .HasMaxLength(256);

        builder.Property(a => a.Username)
            .IsRequired(false)
            .HasMaxLength(256);

        builder.Property(a => a.IpAddress)
            .IsRequired()
            .HasMaxLength(45); // IPv6 max length

        builder.Property(a => a.CreatedAt)
            .IsRequired();

        builder.Property(a => a.FailureReason)
            .IsRequired(false)
            .HasMaxLength(1000);

        // Indexes for common query patterns
        builder.HasIndex(a => a.EventType)
            .HasDatabaseName("IX_AuditEvents_EventType");

        builder.HasIndex(a => a.Protocol)
            .HasDatabaseName("IX_AuditEvents_Protocol");

        builder.HasIndex(a => a.Username)
            .HasDatabaseName("IX_AuditEvents_Username");

        builder.HasIndex(a => a.CreatedAt)
            .HasDatabaseName("IX_AuditEvents_OccurredAt");

        // Composite index for common queries (username + timestamp)
        builder.HasIndex(a => new { a.Username, a.CreatedAt })
            .HasDatabaseName("IX_AuditEvents_Username_OccurredAt");
    }
}
