using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Persistence.Data.Configurations;

public class TimeZoneMasterConfiguration : IEntityTypeConfiguration<TimeZoneMaster>
{
    public void Configure(EntityTypeBuilder<TimeZoneMaster> builder)
    {
        builder.ToTable("TimeZoneMaster");
        builder.HasIndex(x => x.TimeZoneCode).IsUnique();
        builder.HasIndex(x => x.IanaTimeZoneId);
        builder.HasIndex(x => x.WindowsTimeZoneId);
    }
}

public class CountryConfiguration : IEntityTypeConfiguration<Country>
{
    public void Configure(EntityTypeBuilder<Country> builder)
    {
        builder.ToTable("Country");
        builder.HasIndex(x => x.CountryCode).IsUnique();
    }
}

public class RegionConfiguration : IEntityTypeConfiguration<Region>
{
    public void Configure(EntityTypeBuilder<Region> builder)
    {
        builder.ToTable("Region");
        builder.HasOne(x => x.ParentRegion).WithMany().HasForeignKey(x => x.ParentRegionId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class LegalEntityConfiguration : IEntityTypeConfiguration<LegalEntity>
{
    public void Configure(EntityTypeBuilder<LegalEntity> builder)
    {
        builder.ToTable("LegalEntity");
        builder.HasIndex(x => x.EntityCode).IsUnique();
    }
}

public class OfficeLocationConfiguration : IEntityTypeConfiguration<OfficeLocation>
{
    public void Configure(EntityTypeBuilder<OfficeLocation> builder)
    {
        builder.ToTable("OfficeLocation");
        builder.HasIndex(x => x.LocationCode).IsUnique();
        builder.Property(x => x.Latitude).HasColumnType("decimal(10,7)");
        builder.Property(x => x.Longitude).HasColumnType("decimal(10,7)");
    }
}

public class DepartmentConfiguration : IEntityTypeConfiguration<Department>
{
    public void Configure(EntityTypeBuilder<Department> builder)
    {
        builder.ToTable("Department");
        builder.HasIndex(x => x.DepartmentCode).IsUnique();
        builder.HasOne(x => x.ParentDepartment).WithMany().HasForeignKey(x => x.ParentDepartmentId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class ScopeTypeConfiguration : IEntityTypeConfiguration<ScopeType>
{
    public void Configure(EntityTypeBuilder<ScopeType> builder)
    {
        builder.ToTable("ScopeType");
        builder.HasIndex(x => x.ScopeCode).IsUnique();
        builder.HasIndex(x => x.HierarchyLevel);
    }
}

public class DesignationConfiguration : IEntityTypeConfiguration<Designation>
{
    public void Configure(EntityTypeBuilder<Designation> builder)
    {
        builder.ToTable("Designation");
        builder.HasIndex(x => x.DesignationCode).IsUnique();
    }
}

public class DocumentTypeConfiguration : IEntityTypeConfiguration<DocumentType>
{
    public void Configure(EntityTypeBuilder<DocumentType> builder)
    {
        builder.ToTable("DocumentType");
        builder.HasIndex(x => x.DocumentTypeCode).IsUnique();
    }
}

public class GeoFenceConfiguration : IEntityTypeConfiguration<GeoFence>
{
    public void Configure(EntityTypeBuilder<GeoFence> builder)
    {
        builder.ToTable("GeoFence");
        builder.HasIndex(x => x.GeoFenceCode).IsUnique();
        builder.Property(x => x.Latitude).HasColumnType("decimal(18,8)");
        builder.Property(x => x.Longitude).HasColumnType("decimal(18,8)");
        builder.Property(x => x.RadiusMeters).HasColumnType("decimal(18,2)");
    }
}

public class BiometricDeviceConfiguration : IEntityTypeConfiguration<BiometricDevice>
{
    public void Configure(EntityTypeBuilder<BiometricDevice> builder)
    {
        builder.ToTable("BiometricDevice");
        builder.HasIndex(x => x.DeviceCode).IsUnique();
    }
}
