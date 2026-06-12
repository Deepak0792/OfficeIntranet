namespace SdxCore.Employee.Application.DTOs.Employee.Request;

public class CreateEmployeeRequest
{
    public required string EmployeeCode { get; set; }
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public required string Email { get; set; }
    public string? MobileNumber { get; set; }

    /// <summary>Cross-schema FK to time.Designation.</summary>
    public Guid? DesignationId { get; set; }

    public string? PreferredLanguage { get; set; }

    /// <summary>Cross-schema FK to time.TimeZoneMaster.</summary>
    public Guid? PreferredTimeZoneId { get; set; }

    public DateOnly? DateOfJoining { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group EMPLOYMENT_TYPE (e.g. FULL_TIME, PART_TIME).</summary>
    public string EmploymentType { get; set; } = "FULL_TIME";

    public string? AboutMe { get; set; }

    /// <summary>URL of the employee's profile photo (stored via File microservice).</summary>
    public string? ProfilePhotoUrl { get; set; }

    public bool IsSystemEmployee { get; set; } = false;
}
