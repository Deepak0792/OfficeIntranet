using System;
namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeResponse
{
    public int Id { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string Email { get; set; } = null!;
    public string? MobileNumber { get; set; }
    public short? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public short? PreferredTimeZoneId { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = null!;
    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; }
    public int? LastUpdatedBy { get; set; }
}
