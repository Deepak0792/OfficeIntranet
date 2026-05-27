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
