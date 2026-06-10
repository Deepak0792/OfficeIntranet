using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeRequest
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
    public bool IsSystemEmployee { get; set; } = false;
}
