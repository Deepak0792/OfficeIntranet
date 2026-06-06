using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;
public class Employee : BaseAuditEntity<int>, IPublishableEntity
{
    public required string EmployeeCode { get; set; }
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public required string Email { get; set; }
    public string? MobileNumber { get; set; }
    public short? DesignationId { get; set; }
    public string? PreferredLanguage { get; set; }
    public short? PreferredTimeZoneId { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = "FULL_TIME";
    public string? AboutMe { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public bool IsSystemEmployee { get; set; } = false;
    public bool IsActive { get; set; } = true;
}
