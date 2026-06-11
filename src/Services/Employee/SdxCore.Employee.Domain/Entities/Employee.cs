using SdxCore.SharedKernel.Contracts;
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
    public Guid? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public Guid? PreferredTimeZoneId { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = "FULL_TIME";
    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; } = false;
    public bool IsActive { get; set; } = true;

    // REQUIRED NAVIGATION PROPERTIES
    public ICollection<EmployeeSkill> Skills { get; set; } = new List<EmployeeSkill>();
    public ICollection<EmployeeTeam> Teams { get; set; } = new List<EmployeeTeam>();
    public ICollection<EmployeeBiometricMapping> BiometricMappings { get; set; } = new List<EmployeeBiometricMapping>();
    public ICollection<EmployeeDepartment> Departments { get; set; } = new List<EmployeeDepartment>();
    public ICollection<EmployeeLocation> Locations { get; set; } = new List<EmployeeLocation>();
    public ICollection<EmployeeContact> Contacts { get; set; } = new List<EmployeeContact>();
    public ICollection<EmployeeDocument> Documents { get; set; } = new List<EmployeeDocument>();
    public ICollection<EmployeeAddress> Addresses { get; set; } = new List<EmployeeAddress>();
}
