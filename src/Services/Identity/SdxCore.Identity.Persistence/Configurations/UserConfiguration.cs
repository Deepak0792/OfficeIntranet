using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Persistence.Configurations;

/// <summary>
/// Entity Framework Core configuration for the User entity.
/// Defines table schema, indexes, constraints, and column types using Fluent API.
/// </summary>
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    /// <summary>
    /// Configures the User entity.
    /// </summary>
    /// <param name="builder">The builder to be used to configure the entity type.</param>
    public void Configure(EntityTypeBuilder<User> builder)
    {
        // Table name
        builder.ToTable("Users");

        // Primary key
        builder.HasKey(u => u.Id);

        // Properties
        builder.Property(u => u.Id)
            .IsRequired()
            .ValueGeneratedOnAdd();

        builder.Property(u => u.Username)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(u => u.PasswordHash)
            .IsRequired()
            .HasMaxLength(512);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(u => u.IsActive)
            .IsRequired()
            .HasDefaultValue(true);

        builder.Property(u => u.FailedAttempts)
            .IsRequired()
            .HasDefaultValue(0);

        builder.Property(u => u.LockedUntil)
            .IsRequired(false);

        builder.Property(u => u.CreatedAt)
            .IsRequired();

        builder.Property(u => u.LastLoginAt)
            .IsRequired(false);

        // Indexes
        builder.HasIndex(u => u.Username)
            .IsUnique()
            .HasDatabaseName("IX_Users_Username");

        builder.HasIndex(u => u.Email)
            .HasDatabaseName("IX_Users_Email");

        builder.HasIndex(u => u.IsActive)
            .HasDatabaseName("IX_Users_IsActive");
    }
}
