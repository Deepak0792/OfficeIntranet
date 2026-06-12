using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.SharedKernel.Entities;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Persistence.Data.Configurations;

/// <summary>
/// Consolidates all IEntityTypeConfiguration&lt;T&gt; classes for the time schema.
/// Applied via ApplyConfigurationsFromAssembly in TimeDbContext.
///
/// Schema boundary rule:
///   All entities in this file belong to the time schema.
///   No cross-schema navigation properties are defined here.
/// </summary>

public sealed class TimeZoneMasterConfiguration : IEntityTypeConfiguration<TimeZoneMaster>
{
    public void Configure(EntityTypeBuilder<TimeZoneMaster> builder)
    {
        builder.ToTable("TimeZoneMaster");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.TimeZoneCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.TimeZoneName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.UtcOffset).HasMaxLength(20).IsRequired();
        builder.Property(e => e.WindowsTimeZoneId).HasMaxLength(200);
        builder.Property(e => e.IanaTimeZoneId).HasMaxLength(200);
        builder.Property(e => e.CountryCode).HasMaxLength(10);

        builder.HasIndex(e => e.TimeZoneCode).IsUnique();
        builder.HasIndex(e => e.IanaTimeZoneId);
        builder.HasIndex(e => e.WindowsTimeZoneId);

        // Reverse navigation: countries that reference this timezone
        builder.HasMany(e => e.Countries)
            .WithOne(c => c.TimeZone)
            .HasForeignKey(c => c.TimeZoneId)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);
    }
}

public sealed class CountryConfiguration : IEntityTypeConfiguration<Country>
{
    public void Configure(EntityTypeBuilder<Country> builder)
    {
        builder.ToTable("Country");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.CountryCode).HasMaxLength(10).IsRequired();
        builder.Property(e => e.CountryName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.CurrencyCode).HasMaxLength(10);

        builder.HasIndex(e => e.CountryCode).IsUnique();

        // TimeZone nav is configured from TimeZoneMasterConfiguration

        // Reverse navigation to regions
        builder.HasMany(e => e.Regions)
            .WithOne(r => r.Country)
            .HasForeignKey(r => r.CountryId)
            .OnDelete(DeleteBehavior.Restrict);

        // Reverse navigation to legal entities
        builder.HasMany(e => e.LegalEntities)
            .WithOne(le => le.Country)
            .HasForeignKey(le => le.CountryId)
            .OnDelete(DeleteBehavior.Restrict);

        // Reverse navigation to office locations
        builder.HasMany(e => e.OfficeLocations)
            .WithOne(ol => ol.Country)
            .HasForeignKey(ol => ol.CountryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class RegionConfiguration : IEntityTypeConfiguration<Region>
{
    public void Configure(EntityTypeBuilder<Region> builder)
    {
        builder.ToTable("Region");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.RegionName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.RegionType).HasMaxLength(50);

        builder.HasIndex(e => e.CountryId);
        builder.HasIndex(e => e.ParentRegionId);

        // Country nav configured from CountryConfiguration

        // Self-referencing hierarchy
        builder.HasOne(e => e.ParentRegion)
            .WithMany(e => e.ChildRegions)
            .HasForeignKey(e => e.ParentRegionId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class LegalEntityConfiguration : IEntityTypeConfiguration<LegalEntity>
{
    public void Configure(EntityTypeBuilder<LegalEntity> builder)
    {
        builder.ToTable("LegalEntity");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EntityCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.EntityName).HasMaxLength(300).IsRequired();
        builder.Property(e => e.TaxIdentificationNumber).HasMaxLength(100);
        builder.Property(e => e.RegistrationNumber).HasMaxLength(100);
        builder.Property(e => e.CurrencyCode).HasMaxLength(10);

        builder.HasIndex(e => e.EntityCode).IsUnique();
        builder.HasIndex(e => e.CountryId);

        // Country nav configured from CountryConfiguration

        // Reverse navigation to office locations
        builder.HasMany(e => e.OfficeLocations)
            .WithOne(ol => ol.LegalEntity)
            .HasForeignKey(ol => ol.LegalEntityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class OfficeLocationConfiguration : IEntityTypeConfiguration<OfficeLocation>
{
    public void Configure(EntityTypeBuilder<OfficeLocation> builder)
    {
        builder.ToTable("OfficeLocation");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.LocationCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.LocationName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.BuildingName).HasMaxLength(200);
        builder.Property(e => e.AddressLine1).HasMaxLength(500);
        builder.Property(e => e.AddressLine2).HasMaxLength(500);
        builder.Property(e => e.City).HasMaxLength(100);
        builder.Property(e => e.StateProvince).HasMaxLength(100);
        builder.Property(e => e.PostalCode).HasMaxLength(20);
        builder.Property(e => e.Latitude).HasColumnType("decimal(10,7)");
        builder.Property(e => e.Longitude).HasColumnType("decimal(10,7)");

        builder.HasIndex(e => e.LocationCode).IsUnique();
        builder.HasIndex(e => e.LegalEntityId);
        builder.HasIndex(e => e.CountryId);
        builder.HasIndex(e => e.RegionId);

        // LegalEntity nav configured from LegalEntityConfiguration
        // Country nav configured from CountryConfiguration

        // Region nav (optional FK)
        builder.HasOne(e => e.Region)
            .WithMany()
            .HasForeignKey(e => e.RegionId)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);

        // TimeZone nav (optional FK)
        builder.HasOne(e => e.TimeZone)
            .WithMany()
            .HasForeignKey(e => e.TimeZoneId)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);

        // Reverse navigation to GeoFences
        builder.HasMany(e => e.GeoFences)
            .WithOne(g => g.Office)
            .HasForeignKey(g => g.OfficeId)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);

        // Reverse navigation to BiometricDevices
        builder.HasMany(e => e.BiometricDevices)
            .WithOne(b => b.Office)
            .HasForeignKey(b => b.OfficeId)
            .OnDelete(DeleteBehavior.SetNull)
            .IsRequired(false);
    }
}

public sealed class DepartmentConfiguration : IEntityTypeConfiguration<Department>
{
    public void Configure(EntityTypeBuilder<Department> builder)
    {
        builder.ToTable("Department");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DepartmentCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.DepartmentName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);

        builder.HasIndex(e => e.DepartmentCode).IsUnique();
        builder.HasIndex(e => e.ParentDepartmentId);

        // Self-referencing hierarchy
        builder.HasOne(e => e.ParentDepartment)
            .WithMany(e => e.ChildDepartments)
            .HasForeignKey(e => e.ParentDepartmentId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class ScopeTypeConfiguration : IEntityTypeConfiguration<ScopeType>
{
    public void Configure(EntityTypeBuilder<ScopeType> builder)
    {
        builder.ToTable("ScopeType");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.ScopeCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.ScopeName).HasMaxLength(200).IsRequired();

        builder.HasIndex(e => e.ScopeCode).IsUnique();
        builder.HasIndex(e => e.HierarchyLevel);
    }
}

public sealed class DesignationConfiguration : IEntityTypeConfiguration<Designation>
{
    public void Configure(EntityTypeBuilder<Designation> builder)
    {
        builder.ToTable("Designation");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DesignationCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.DesignationName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Grade).HasMaxLength(50);

        builder.HasIndex(e => e.DesignationCode).IsUnique();
    }
}

public sealed class DocumentTypeConfiguration : IEntityTypeConfiguration<DocumentType>
{
    public void Configure(EntityTypeBuilder<DocumentType> builder)
    {
        builder.ToTable("DocumentType");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DocumentTypeCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.DocumentTypeName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Category).HasMaxLength(100);
        builder.Property(e => e.Description).HasMaxLength(1000);

        builder.HasIndex(e => e.DocumentTypeCode).IsUnique();
    }
}

public sealed class GeoFenceConfiguration : IEntityTypeConfiguration<GeoFence>
{
    public void Configure(EntityTypeBuilder<GeoFence> builder)
    {
        builder.ToTable("GeoFence");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.GeoFenceCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.GeoFenceName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Latitude).HasColumnType("decimal(18,8)");
        builder.Property(e => e.Longitude).HasColumnType("decimal(18,8)");
        builder.Property(e => e.RadiusMeters).HasColumnType("decimal(18,2)");

        builder.HasIndex(e => e.GeoFenceCode).IsUnique();
        builder.HasIndex(e => e.OfficeId);

        // Office nav configured from OfficeLocationConfiguration
    }
}

public sealed class BiometricDeviceConfiguration : IEntityTypeConfiguration<BiometricDevice>
{
    public void Configure(EntityTypeBuilder<BiometricDevice> builder)
    {
        builder.ToTable("BiometricDevice");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DeviceCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.DeviceName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.SerialNumber).HasMaxLength(200);
        builder.Property(e => e.IpAddress).HasMaxLength(100);

        builder.HasIndex(e => e.DeviceCode).IsUnique();
        builder.HasIndex(e => e.OfficeId);

        // Office nav configured from OfficeLocationConfiguration
    }
}

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.ToTable("OutboxMessages", "time");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EventType).HasMaxLength(500).IsRequired();
        builder.Property(e => e.Exchange).HasMaxLength(200).IsRequired();
        builder.Property(e => e.RoutingKey).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Status).HasMaxLength(50).IsRequired();
    }
}
