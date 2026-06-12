using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class Employee : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string EmployeeCode { get; set; }
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public required string Email { get; set; }
    public string? MobileNumber { get; set; }

    // Cross-schema FK to time.Designation — no nav prop
    public Guid? DesignationId { get; set; }

    public string? PreferredLanguage { get; set; }

    // Cross-schema FK to time.TimeZoneMaster — no nav prop
    public Guid? PreferredTimeZoneId { get; set; }

    public DateOnly? DateOfJoining { get; set; }

    /// <summary>Lookup-backed employment type (e.g. FULL_TIME, PART_TIME). FK to shared.StatusLookup.</summary>
    public string EmploymentType { get; set; } = "FULL_TIME";

    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; } = false;
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties (all belong to employee schema) ─────

    /// <summary>Skills associated with this employee.</summary>
    public ICollection<EmployeeSkill> Skills { get; set; } = new List<EmployeeSkill>();

    /// <summary>Team memberships for this employee.</summary>
    public ICollection<EmployeeTeam> Teams { get; set; } = new List<EmployeeTeam>();

    /// <summary>Biometric device mappings for this employee.</summary>
    public ICollection<EmployeeBiometricMapping> BiometricMappings { get; set; } = new List<EmployeeBiometricMapping>();

    /// <summary>Department assignments for this employee (cross-schema IDs, intra-schema junction entity).</summary>
    public ICollection<EmployeeDepartment> Departments { get; set; } = new List<EmployeeDepartment>();

    /// <summary>Location assignments for this employee (cross-schema IDs, intra-schema junction entity).</summary>
    public ICollection<EmployeeLocation> Locations { get; set; } = new List<EmployeeLocation>();

    /// <summary>Contact details for this employee.</summary>
    public ICollection<EmployeeContact> Contacts { get; set; } = new List<EmployeeContact>();

    /// <summary>Documents uploaded for this employee.</summary>
    public ICollection<EmployeeDocument> Documents { get; set; } = new List<EmployeeDocument>();

    /// <summary>Addresses for this employee.</summary>
    public ICollection<EmployeeAddress> Addresses { get; set; } = new List<EmployeeAddress>();

    /// <summary>Relationships where this employee is the parent (manager/mentor).</summary>
    public ICollection<EmployeeRelationship> ParentRelationships { get; set; } = new List<EmployeeRelationship>();

    /// <summary>Relationships where this employee is the child (reportee/mentee).</summary>
    public ICollection<EmployeeRelationship> ChildRelationships { get; set; } = new List<EmployeeRelationship>();

    /// <summary>Legal entity assignments for this employee (cross-schema IDs, intra-schema junction entity).</summary>
    public ICollection<EmployeeLegalEntity> LegalEntities { get; set; } = new List<EmployeeLegalEntity>();
}
