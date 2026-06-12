using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Employee.Domain.Entities;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Persistence.Data.Configurations;

/// <summary>
/// Consolidates all IEntityTypeConfiguration&lt;T&gt; classes for the Employee schema.
/// Applied via ApplyConfigurationsFromAssembly in EmployeeDbContext.
///
/// Schema boundary rule:
///   - Navigation properties are ONLY configured for entities within the employee schema.
///   - Cross-schema FKs (time.*, shared.*, workflow.*) are stored as plain IDs — EF is NOT
///     told about them to avoid cross-schema constraint conflicts during migrations.
/// </summary>

public sealed class EmployeeConfiguration : IEntityTypeConfiguration<Domain.Entities.Employee>
{
    public void Configure(EntityTypeBuilder<Domain.Entities.Employee> builder)
    {
        builder.ToTable("Employee");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EmployeeCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(e => e.LastName).HasMaxLength(100);
        builder.Property(e => e.DisplayName).HasMaxLength(200);
        builder.Property(e => e.Email).HasMaxLength(255).IsRequired();
        builder.Property(e => e.MobileNumber).HasMaxLength(30);
        builder.Property(e => e.PreferredLanguage).HasMaxLength(20);
        builder.Property(e => e.EmploymentType).HasMaxLength(50).IsRequired();
        builder.Property(e => e.ProfilePhotoUrl).HasMaxLength(1000);

        // EmploymentTypeGroup is a computed/persisted column — EF should not write to it
        builder.Property<string>("EmploymentTypeGroup")
            .HasComputedColumnSql("CAST('EMPLOYMENT_TYPE' AS NVARCHAR(50))", stored: true);

        // ── Intra-schema one-to-many relationships ────────────────────────────

        builder.HasMany(e => e.Skills)
            .WithOne(s => s.Employee)
            .HasForeignKey(s => s.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Teams)
            .WithOne(t => t.Employee)
            .HasForeignKey(t => t.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.BiometricMappings)
            .WithOne(b => b.Employee)
            .HasForeignKey(b => b.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Departments)
            .WithOne(d => d.Employee)
            .HasForeignKey(d => d.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Locations)
            .WithOne(l => l.Employee)
            .HasForeignKey(l => l.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Contacts)
            .WithOne(c => c.Employee)
            .HasForeignKey(c => c.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Documents)
            .WithOne(d => d.Employee)
            .HasForeignKey(d => d.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Addresses)
            .WithOne(a => a.Employee)
            .HasForeignKey(a => a.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.LegalEntities)
            .WithOne(le => le.Employee)
            .HasForeignKey(le => le.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        // ── Self-referencing relationships via EmployeeRelationship ───────────

        builder.HasMany(e => e.ParentRelationships)
            .WithOne(r => r.ParentEmployee)
            .HasForeignKey(r => r.ParentEmployeeId)
            .OnDelete(DeleteBehavior.Restrict); // Restrict to avoid cascade cycles

        builder.HasMany(e => e.ChildRelationships)
            .WithOne(r => r.ChildEmployee)
            .HasForeignKey(r => r.ChildEmployeeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class EmployeeSummaryConfiguration : IEntityTypeConfiguration<EmployeeSummary>
{
    public void Configure(EntityTypeBuilder<EmployeeSummary> builder)
    {
        builder.ToView("vwEmployeeSummary");
        builder.HasNoKey();
    }
}

public sealed class SkillConfiguration : IEntityTypeConfiguration<Skill>
{
    public void Configure(EntityTypeBuilder<Skill> builder)
    {
        builder.ToTable("Skill");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.SkillName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.SkillCategory).HasMaxLength(100);
        builder.Property(e => e.Description).HasMaxLength(1000);
    }
}

public sealed class EmployeeSkillConfiguration : IEntityTypeConfiguration<EmployeeSkill>
{
    public void Configure(EntityTypeBuilder<EmployeeSkill> builder)
    {
        builder.ToTable("EmployeeSkill");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.SkillLevel).HasMaxLength(50);

        // Intra-schema: Skill belongs to employee schema
        builder.HasOne(d => d.Skill)
            .WithMany(p => p.EmployeeSkills)
            .HasForeignKey(d => d.SkillId)
            .OnDelete(DeleteBehavior.Restrict);
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class TeamConfiguration : IEntityTypeConfiguration<Team>
{
    public void Configure(EntityTypeBuilder<Team> builder)
    {
        builder.ToTable("Team");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.TeamCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.TeamName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.TeamType).HasMaxLength(100);
        builder.Property(e => e.Description).HasMaxLength(1000);
    }
}

public sealed class EmployeeTeamConfiguration : IEntityTypeConfiguration<EmployeeTeam>
{
    public void Configure(EntityTypeBuilder<EmployeeTeam> builder)
    {
        builder.ToTable("EmployeeTeam");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.RoleInTeam).HasMaxLength(100);

        // Intra-schema: Team belongs to employee schema
        builder.HasOne(d => d.Team)
            .WithMany(p => p.EmployeeTeams)
            .HasForeignKey(d => d.TeamId)
            .OnDelete(DeleteBehavior.Restrict);
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeBiometricMappingConfiguration : IEntityTypeConfiguration<EmployeeBiometricMapping>
{
    public void Configure(EntityTypeBuilder<EmployeeBiometricMapping> builder)
    {
        builder.ToTable("EmployeeBiometricMapping");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DeviceEmployeeCode).HasMaxLength(100).IsRequired();

        // BiometricDeviceId: cross-schema FK to time.BiometricDevice — ID only, no EF relationship
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeLegalEntityConfiguration : IEntityTypeConfiguration<EmployeeLegalEntity>
{
    public void Configure(EntityTypeBuilder<EmployeeLegalEntity> builder)
    {
        builder.ToTable("EmployeeLegalEntity");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // LegalEntityId: cross-schema FK to time.LegalEntity — ID only, no EF relationship
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeDepartmentConfiguration : IEntityTypeConfiguration<EmployeeDepartment>
{
    public void Configure(EntityTypeBuilder<EmployeeDepartment> builder)
    {
        builder.ToTable("EmployeeDepartment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // DepartmentId: cross-schema FK to time.Department — ID only, no EF relationship
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeLocationConfiguration : IEntityTypeConfiguration<EmployeeLocation>
{
    public void Configure(EntityTypeBuilder<EmployeeLocation> builder)
    {
        builder.ToTable("EmployeeLocation");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // LocationId: cross-schema FK to time.OfficeLocation — ID only, no EF relationship
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeRelationshipConfiguration : IEntityTypeConfiguration<EmployeeRelationship>
{
    public void Configure(EntityTypeBuilder<EmployeeRelationship> builder)
    {
        builder.ToTable("EmployeeRelationship");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.RelationshipType).HasMaxLength(50).IsRequired();

        // RelationshipTypeGroup is a computed/persisted column — EF should not write to it
        builder.Property<string>("RelationshipTypeGroup")
            .HasComputedColumnSql("CAST('RELATIONSHIP_TYPE' AS NVARCHAR(50))", stored: true);

        // DepartmentId: cross-schema FK to time.Department — ID only, no EF relationship

        // Both self-referencing FKs are configured from EmployeeConfiguration to avoid duplicate mappings.
        // They use Restrict to prevent EF cascade cycles.
    }
}

public sealed class EmployeeContactConfiguration : IEntityTypeConfiguration<EmployeeContact>
{
    public void Configure(EntityTypeBuilder<EmployeeContact> builder)
    {
        builder.ToTable("EmployeeContact");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.ContactType).HasMaxLength(50).IsRequired();
        builder.Property(e => e.ContactValue).HasMaxLength(500).IsRequired();

        // ContactTypeGroup is a computed/persisted column — EF should not write to it
        builder.Property<string>("ContactTypeGroup")
            .HasComputedColumnSql("CAST('CONTACT_TYPE' AS NVARCHAR(50))", stored: true);

        // ContactType + ContactTypeGroup FK to shared.StatusLookup — cross-schema, not mapped in EF
        // Employee relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeDocumentConfiguration : IEntityTypeConfiguration<EmployeeDocument>
{
    public void Configure(EntityTypeBuilder<EmployeeDocument> builder)
    {
        builder.ToTable("EmployeeDocument");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.FileName).HasMaxLength(500);
        builder.Property(e => e.OriginalFileName).HasMaxLength(500);
        builder.Property(e => e.FileExtension).HasMaxLength(20);
        builder.Property(e => e.MimeType).HasMaxLength(100);
        builder.Property(e => e.FileUrl).HasMaxLength(1000);
        builder.Property(e => e.DocumentNumber).HasMaxLength(200);
        builder.Property(e => e.Remarks).HasMaxLength(1000);

        // DocumentTypeId: cross-schema FK to time.DocumentType — ID only, no EF relationship
        // WorkflowInstanceId: cross-schema FK to workflow.WorkflowInstance — ID only, no EF relationship

        // Intra-schema: VerifiedByEmployeeId points to employee.Employee
        builder.HasOne(d => d.VerifierEmployee)
            .WithMany()
            .HasForeignKey(d => d.VerifiedByEmployeeId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // Employee (owner) relationship configured from EmployeeConfiguration
    }
}

public sealed class EmployeeAddressConfiguration : IEntityTypeConfiguration<EmployeeAddress>
{
    public void Configure(EntityTypeBuilder<EmployeeAddress> builder)
    {
        builder.ToTable("EmployeeAddress");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.AddressType).HasMaxLength(50).IsRequired();
        builder.Property(e => e.AddressLine1).HasMaxLength(500).IsRequired();
        builder.Property(e => e.AddressLine2).HasMaxLength(500);
        builder.Property(e => e.Landmark).HasMaxLength(300);
        builder.Property(e => e.City).HasMaxLength(100).IsRequired();
        builder.Property(e => e.StateProvince).HasMaxLength(100);
        builder.Property(e => e.PostalCode).HasMaxLength(20);

        // AddressTypeGroup is a computed/persisted column — EF should not write to it
        builder.Property<string>("AddressTypeGroup")
            .HasComputedColumnSql("CAST('ADDRESS_TYPE' AS NVARCHAR(50))", stored: true);

        // CountryId, RegionId: cross-schema FKs to time.Country / time.Region — ID only, no EF relationship
        // WorkflowInstanceId: cross-schema FK to workflow.WorkflowInstance — ID only, no EF relationship

        // Intra-schema: VerifiedByEmployeeId points to employee.Employee
        builder.HasOne(a => a.VerifierEmployee)
            .WithMany()
            .HasForeignKey(a => a.VerifiedByEmployeeId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // Employee (owner) relationship configured from EmployeeConfiguration
    }
}

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.ToTable("OutboxMessages", "employee");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EventType).HasMaxLength(500).IsRequired();
        builder.Property(e => e.Exchange).HasMaxLength(200).IsRequired();
        builder.Property(e => e.RoutingKey).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Status).HasMaxLength(50).IsRequired();
    }
}
