using System;
namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeFullProfileResponse
{
    public int EmployeeId { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public string Email { get; set; } = null!;
    public string? MobileNumber { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public string EmploymentType { get; set; } = null!;
    public bool IsActive { get; set; }
    
    public short? PrimaryDepartmentId { get; set; }
    public string? PrimaryDepartmentName { get; set; }
    
    public short? DesignationId { get; set; }
    public string? DesignationName { get; set; }
    public string? Grade { get; set; }
    
    public short? PrimaryLocationId { get; set; }
    public string? PrimaryLocationName { get; set; }
    public string? PrimaryLocationCity { get; set; }
    
    public short? PrimaryLegalEntityId { get; set; }
    public string? PrimaryLegalEntityName { get; set; }
    
    public int? DirectManagerId { get; set; }
    public string? DirectManagerName { get; set; }
}
