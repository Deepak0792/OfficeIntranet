using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class UpdateEmployeeRequest
{
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string? MobileNumber { get; set; }
    public short? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public short? PreferredTimeZoneId { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public required string EmploymentType { get; set; }
}
