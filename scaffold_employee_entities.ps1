$entitiesDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Domain\Entities"
New-Item -ItemType Directory -Force -Path $entitiesDir | Out-Null

$employeeCode = @"
using System;
using System.Collections.Generic;

namespace SdxCore.Employee.Domain.Entities;

public class Employee : BaseEntity
{
    public int Id { get; set; }
    public string EmployeeCode { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string Email { get; set; } = string.Empty;
    public string? MobileNumber { get; set; }
    public short? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public short? PreferredTimeZoneId { get; set; }
    public DateTime? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = "FULL_TIME";
    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; } = false;

    public ICollection<EmployeeLegalEntity> LegalEntities { get; set; } = new List<EmployeeLegalEntity>();
    public ICollection<EmployeeDepartment> Departments { get; set; } = new List<EmployeeDepartment>();
    public ICollection<EmployeeLocation> Locations { get; set; } = new List<EmployeeLocation>();
    public ICollection<EmployeeRelationship> ParentRelationships { get; set; } = new List<EmployeeRelationship>();
    public ICollection<EmployeeRelationship> ChildRelationships { get; set; } = new List<EmployeeRelationship>();
    public ICollection<EmployeeContact> Contacts { get; set; } = new List<EmployeeContact>();
    public ICollection<EmployeeDocument> Documents { get; set; } = new List<EmployeeDocument>();
    public ICollection<EmployeeSkill> Skills { get; set; } = new List<EmployeeSkill>();
    public ICollection<EmployeeTeam> Teams { get; set; } = new List<EmployeeTeam>();
    public ICollection<BiometricEmployeeMapping> BiometricMappings { get; set; } = new List<BiometricEmployeeMapping>();
    public ICollection<EmployeeAddress> Addresses { get; set; } = new List<EmployeeAddress>();
}
"@
Set-Content -Path "$entitiesDir\Employee.cs" -Value $employeeCode

$legalEntityCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LegalEntityId { get; set; }
    public bool IsPrimary { get; set; } = false;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeLegalEntity.cs" -Value $legalEntityCode

$deptCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDepartment : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; } = false;
    public decimal? AllocationPercentage { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeDepartment.cs" -Value $deptCode

$locCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLocation : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; } = true;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeLocation.cs" -Value $locCode

$relCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseEntity
{
    public int Id { get; set; }
    public int ParentEmployeeId { get; set; }
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = string.Empty;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; } = false;
    public DateTime? EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }

    public Employee? ParentEmployee { get; set; }
    public Employee? ChildEmployee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeRelationship.cs" -Value $relCode

$contactCode = @"
namespace SdxCore.Employee.Domain.Entities;

public class EmployeeContact : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string ContactType { get; set; } = string.Empty;
    public string ContactValue { get; set; } = string.Empty;
    public bool IsPrimary { get; set; } = false;

    public Employee? Employee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeContact.cs" -Value $contactCode

$docCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDocument : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DocumentTypeId { get; set; }
    public string? FileName { get; set; }
    public string? OriginalFileName { get; set; }
    public string? FileExtension { get; set; }
    public string? MimeType { get; set; }
    public int? FileSizeInBytes { get; set; }
    public string? FileUrl { get; set; }
    public string? DocumentNumber { get; set; }
    public DateTime? IssuedDate { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public string? Remarks { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public bool IsVerified { get; set; } = false;
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public int? WorkflowInstanceId { get; set; }

    public Employee? Employee { get; set; }
    public Employee? VerifiedByEmployee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeDocument.cs" -Value $docCode

$skillCode = @"
using System.Collections.Generic;

namespace SdxCore.Employee.Domain.Entities;

public class Skill : BaseEntity
{
    public short Id { get; set; }
    public string SkillName { get; set; } = string.Empty;
    public string? SkillCategory { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeSkill> EmployeeSkills { get; set; } = new List<EmployeeSkill>();
}
"@
Set-Content -Path "$entitiesDir\Skill.cs" -Value $skillCode

$empSkillCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeSkill : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short SkillId { get; set; }
    public string? SkillLevel { get; set; }
    public decimal? YearsOfExperience { get; set; }
    public bool IsPrimarySkill { get; set; } = false;
    public DateTime? LastUsedDate { get; set; }

    public Employee? Employee { get; set; }
    public Skill? Skill { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeSkill.cs" -Value $empSkillCode

$teamCode = @"
using System.Collections.Generic;

namespace SdxCore.Employee.Domain.Entities;

public class Team : BaseEntity
{
    public short Id { get; set; }
    public string TeamCode { get; set; } = string.Empty;
    public string TeamName { get; set; } = string.Empty;
    public string? TeamType { get; set; }
    public string? Description { get; set; }

    public ICollection<EmployeeTeam> EmployeeTeams { get; set; } = new List<EmployeeTeam>();
}
"@
Set-Content -Path "$entitiesDir\Team.cs" -Value $teamCode

$empTeamCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeTeam : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short TeamId { get; set; }
    public string? RoleInTeam { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
    public Team? Team { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeTeam.cs" -Value $empTeamCode

$bioCode = @"
namespace SdxCore.Employee.Domain.Entities;

public class BiometricEmployeeMapping : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public string DeviceEmployeeCode { get; set; } = string.Empty;

    public Employee? Employee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\BiometricEmployeeMapping.cs" -Value $bioCode

$addressCode = @"
using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeAddress : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string AddressType { get; set; } = string.Empty;
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = string.Empty;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public short CountryId { get; set; }
    public short? RegionId { get; set; }
    public bool IsPrimary { get; set; } = false;
    public int? WorkflowInstanceId { get; set; }
    public bool IsVerified { get; set; } = false;
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }

    public Employee? Employee { get; set; }
    public Employee? VerifiedByEmployee { get; set; }
}
"@
Set-Content -Path "$entitiesDir\EmployeeAddress.cs" -Value $addressCode

Write-Output "Successfully generated Employee Domain Entities."
