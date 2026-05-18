$baseDir = "d:\Office\SdxCore\src\Services\Time"

function Write-File ($path, $content) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $path -Value $content.Trim() -Encoding UTF8
}

Write-Host "Generating .csproj files..."
Write-File "$baseDir\SdxCore.Time.Domain\SdxCore.Time.Domain.csproj" @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
"@

Write-File "$baseDir\SdxCore.Time.Application\SdxCore.Time.Application.csproj" @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\SdxCore.Time.Domain\SdxCore.Time.Domain.csproj`" />
  </ItemGroup>
</Project>
"@

Write-File "$baseDir\SdxCore.Time.Persistence\SdxCore.Time.Persistence.csproj" @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include=`"Microsoft.EntityFrameworkCore`" Version=`"9.0.0`" />
    <PackageReference Include=`"Microsoft.EntityFrameworkCore.Relational`" Version=`"9.0.0`" />
    <PackageReference Include=`"Microsoft.EntityFrameworkCore.SqlServer`" Version=`"9.0.0`" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\SdxCore.Time.Domain\SdxCore.Time.Domain.csproj`" />
  </ItemGroup>
</Project>
"@

Write-File "$baseDir\SdxCore.Time.API\SdxCore.Time.API.csproj" @"
<Project Sdk=`"Microsoft.NET.Sdk.Web`">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\SdxCore.Time.Application\SdxCore.Time.Application.csproj`" />
    <ProjectReference Include=`"..\SdxCore.Time.Persistence\SdxCore.Time.Persistence.csproj`" />
  </ItemGroup>
</Project>
"@

Write-Host "Generating Domain Entities..."
$entitiesDir = "$baseDir\SdxCore.Time.Domain\Entities"

Write-File "$entitiesDir\BaseEntity.cs" @"
namespace SdxCore.Time.Domain.Entities;
public abstract class BaseEntity {
    public long Id { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
"@

Write-File "$entitiesDir\TimeZoneMaster.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class TimeZoneMaster : BaseEntity {
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public int OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
}
"@

Write-File "$entitiesDir\Country.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class Country : BaseEntity {
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public long? TimeZoneId { get; set; }
    public TimeZoneMaster? TimeZone { get; set; }
}
"@

Write-File "$entitiesDir\Region.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class Region : BaseEntity {
    public long CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public long? ParentRegionId { get; set; }
    public Country? Country { get; set; }
    public Region? ParentRegion { get; set; }
}
"@

Write-File "$entitiesDir\LegalEntity.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class LegalEntity : BaseEntity {
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public Country? Country { get; set; }
}
"@

Write-File "$entitiesDir\OfficeLocation.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class OfficeLocation : BaseEntity {
    public long LegalEntityId { get; set; }
    public long CountryId { get; set; }
    public long? RegionId { get; set; }
    public required string LocationCode { get; set; }
    public required string LocationName { get; set; }
    public string? BuildingName { get; set; }
    public string? AddressLine1 { get; set; }
    public string? AddressLine2 { get; set; }
    public string? City { get; set; }
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public long? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
    public LegalEntity? LegalEntity { get; set; }
    public Country? Country { get; set; }
    public Region? Region { get; set; }
    public TimeZoneMaster? TimeZone { get; set; }
}
"@

Write-File "$entitiesDir\Department.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class Department : BaseEntity {
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public long? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public Department? ParentDepartment { get; set; }
}
"@

Write-File "$entitiesDir\ScopeType.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class ScopeType : BaseEntity {
    public required string ScopeCode { get; set; }
    public required string ScopeName { get; set; }
    public int HierarchyLevel { get; set; }
}
"@

Write-File "$entitiesDir\Designation.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class Designation : BaseEntity {
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
}
"@

Write-File "$entitiesDir\DocumentType.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class DocumentType : BaseEntity {
    public required string DocumentTypeCode { get; set; }
    public required string DocumentTypeName { get; set; }
    public string? Category { get; set; }
    public string? Description { get; set; }
    public bool IsMandatory { get; set; }
}
"@

Write-File "$entitiesDir\GeoFence.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class GeoFence : BaseEntity {
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public long? OfficeId { get; set; }
    public OfficeLocation? Office { get; set; }
}
"@

Write-File "$entitiesDir\BiometricDevice.cs" @"
namespace SdxCore.Time.Domain.Entities;
public class BiometricDevice : BaseEntity {
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public long? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public OfficeLocation? Office { get; set; }
}
"@

Write-Host "Generating DbContext and configurations..."
$dataDir = "$baseDir\SdxCore.Time.Persistence\Data"
$configDir = "$dataDir\Configurations"

Write-File "$dataDir\TimeDbContext.cs" @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Persistence.Data;

public class TimeDbContext : DbContext
{
    public TimeDbContext(DbContextOptions<TimeDbContext> options) : base(options) { }

    public DbSet<TimeZoneMaster> TimeZoneMasters => Set<TimeZoneMaster>();
    public DbSet<Country> Countries => Set<Country>();
    public DbSet<Region> Regions => Set<Region>();
    public DbSet<LegalEntity> LegalEntities => Set<LegalEntity>();
    public DbSet<OfficeLocation> OfficeLocations => Set<OfficeLocation>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<ScopeType> ScopeTypes => Set<ScopeType>();
    public DbSet<Designation> Designations => Set<Designation>();
    public DbSet<DocumentType> DocumentTypes => Set<DocumentType>();
    public DbSet<GeoFence> GeoFences => Set<GeoFence>();
    public DbSet<BiometricDevice> BiometricDevices => Set<BiometricDevice>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("time");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(TimeDbContext).Assembly);
    }
}
"@

Write-File "$configDir\EntityConfigurations.cs" @"
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
"@

Write-Host "Done."
