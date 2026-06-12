namespace SdxCore.Employee.Application.DTOs.Employee.Request;

public class UpdateEmployeeRequest
{
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string? MobileNumber { get; set; }

    /// <summary>Cross-schema FK to time.Designation.</summary>
    public Guid? DesignationId { get; set; }

    public string? PreferredLanguage { get; set; }

    /// <summary>Cross-schema FK to time.TimeZoneMaster.</summary>
    public Guid? PreferredTimeZoneId { get; set; }

    public DateOnly? DateOfJoining { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group EMPLOYMENT_TYPE.</summary>
    public required string EmploymentType { get; set; }
}
