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
    
    public short? DepartmentId { get; set; }
    public string? DepartmentName { get; set; }
    
    public short? DesignationId { get; set; }
    public string? DesignationName { get; set; }
    public string? Grade { get; set; }
    
    public short? LocationId { get; set; }
    public string? LocationName { get; set; }
    public string? City { get; set; }
    
    public short? PrimaryLegalEntityId { get; set; }
    public string? PrimaryLegalEntityName { get; set; }
    
    public int? ManagerId { get; set; }
    public string? ManagerName { get; set; }
}
