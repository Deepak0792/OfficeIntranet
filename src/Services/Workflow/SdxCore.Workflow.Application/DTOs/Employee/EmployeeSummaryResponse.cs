using System;
namespace SdxCore.Workflow.Application.DTOs.Employee;

public class EmployeeSummaryResponse
{
    private string? _displayName;
    public Guid EmployeeId { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string? LastName { get; set; }

    public string DisplayName
    {
        get => string.IsNullOrWhiteSpace(_displayName)
            ? $"{FirstName} {LastName}".Trim() : _displayName;
        set => _displayName = value;
    }
    public string? ProfilePhotoUrl { get; set; }
    public string Email { get; set; } = null!;
    public string? MobileNumber { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = null!;
    public bool IsActive { get; set; }
    public Guid? PrimaryDepartmentId { get; set; }
    public Guid? PrimaryTeamId { get; set; }
    public Guid? DesignationId { get; set; }
    public Guid? PrimaryLocationId { get; set; }
    public Guid? PrimaryLegalEntityId { get; set; }

    public Guid? DirectManagerId { get; set; }
    public string? DirectManagerName { get; set; }

    // -------------------------------
    // Extra fields (NOT in DB view)
    // -------------------------------

    public string? PrimaryDepartmentName { get; set; }
    public string? DesignationName { get; set; }
    public string? Grade { get; set; }
    public string? PrimaryLocationName { get; set; }
    public string? PrimaryLocationCity { get; set; }
    public string? PrimaryLegalEntityName { get; set; }
}
