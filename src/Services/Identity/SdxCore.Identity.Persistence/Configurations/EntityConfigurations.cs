using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Persistence.Configurations;

/// <summary>
/// Consolidates all IEntityTypeConfiguration&lt;T&gt; classes for the Identity service.
/// Applied via ApplyConfigurationsFromAssembly in IdentityDbContext.
///
/// Schema boundary rule:
///   EmployeeId fields are cross-schema FKs to employee.Employee.
///   EF is NOT configured to follow those as navigation properties.
///   The only intra-schema relationship is User ↔ RefreshToken.
/// </summary>

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Id).ValueGeneratedNever();

        // EmployeeId: cross-schema FK to employee.Employee — unique, no EF nav prop
        builder.Property(u => u.EmployeeId).IsRequired();
        builder.HasIndex(u => u.EmployeeId)
            .IsUnique()
            .HasDatabaseName("UQ_Users_EmployeeId");

        builder.Property(u => u.Username).IsRequired().HasMaxLength(256);
        builder.Property(u => u.PasswordHash).IsRequired().HasMaxLength(512);
        builder.Property(u => u.Email).IsRequired().HasMaxLength(256);
        builder.Property(u => u.FailedAttempts).IsRequired().HasDefaultValue(0);
        builder.Property(u => u.LockedUntil).IsRequired(false);
        builder.Property(u => u.LastLoginAt).IsRequired(false);
        builder.Property(u => u.IsActive).IsRequired().HasDefaultValue(true);

        builder.HasIndex(u => u.Username).IsUnique().HasDatabaseName("IX_Users_Username");
        builder.HasIndex(u => u.Email).HasDatabaseName("IX_Users_Email");
        builder.HasIndex(u => u.IsActive).HasDatabaseName("IX_Users_IsActive");

        // ── Intra-schema relationship ─────────────────────────────────────────
        // FK: RefreshTokens.EmployeeId → Users.EmployeeId (cascade delete)
        builder.HasMany(u => u.RefreshTokens)
            .WithOne(r => r.User)
            .HasForeignKey(r => r.EmployeeId)
            .HasPrincipalKey(u => u.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("RefreshTokens");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Id).ValueGeneratedNever();

        // EmployeeId: FK to Users.EmployeeId — relationship configured from UserConfiguration
        builder.Property(r => r.EmployeeId).IsRequired();
        builder.Property(r => r.HashToken).IsRequired().HasMaxLength(512);
        builder.Property(r => r.RevokedByIp).HasMaxLength(45);
        builder.Property(r => r.ReplacedByHashToken).HasMaxLength(512);
        builder.Property(r => r.UserAgent).HasMaxLength(512);
        builder.Property(r => r.Device).HasMaxLength(256);
        builder.Property(r => r.CreatedByIp).HasMaxLength(45);
        builder.Property(r => r.IsActive).IsRequired().HasDefaultValue(false);
        builder.Property(r => r.RevokedAt).IsRequired(false);
    }
}

public sealed class AuditEventConfiguration : IEntityTypeConfiguration<AuditEvent>
{
    public void Configure(EntityTypeBuilder<AuditEvent> builder)
    {
        builder.ToTable("AuditEvents");
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).ValueGeneratedNever();

        builder.Property(a => a.EventType).IsRequired().HasMaxLength(100);
        builder.Property(a => a.Protocol).IsRequired().HasConversion<string>().HasMaxLength(50);

        // EmployeeId: cross-schema FK to employee.Employee — nullable (failed logins may have no employee)
        builder.Property(a => a.EmployeeId).IsRequired(false);
        builder.Property(a => a.Username).IsRequired(false).HasMaxLength(256);

        // IpAddress is nullable in SQL — may not be available in all auth flows
        builder.Property(a => a.IpAddress).IsRequired(false).HasMaxLength(45);

        // C# property is CreatedAt; SQL column name is OccurredAt
        builder.Property(a => a.CreatedAt)
            .HasColumnName("OccurredAt")
            .IsRequired();

        builder.Property(a => a.FailureReason).IsRequired(false).HasMaxLength(1000);

        builder.HasIndex(a => a.EventType).HasDatabaseName("IX_AuditEvents_EventType");
        builder.HasIndex(a => a.Protocol).HasDatabaseName("IX_AuditEvents_Protocol");
        builder.HasIndex(a => a.Username).HasDatabaseName("IX_AuditEvents_Username");
        builder.HasIndex(a => a.CreatedAt).HasDatabaseName("IX_AuditEvents_CreatedAt");
        builder.HasIndex(a => new { a.Username, a.CreatedAt }).HasDatabaseName("IX_AuditEvents_Username_CreatedAt");
    }
}
