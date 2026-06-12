using System;
namespace SdxCore.Employee.Application.DTOs.Employee.Response;

public class EmployeeResponse
{
    public Guid Id { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string Email { get; set; } = null!;
    public string? MobileNumber { get; set; }
    public Guid? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public Guid? PreferredTimeZoneId { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = null!;
    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public Guid? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; }
    public Guid? LastUpdatedBy { get; set; }
}
