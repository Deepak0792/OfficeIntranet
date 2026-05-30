namespace SdxCore.Employee.Domain.Entities;
using System;

public class EmployeeFullProfile
{
    public int EmployeeId { get; set; }
    public required string EmployeeCode { get; set; }
    public required string FirstName { get; set; }
    public string? LastName { get; set; }
    public string? DisplayName { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public required string Email { get; set; }
    public string? MobileNumber { get; set; }
    public DateOnly? DateOfJoining { get; set; }
    public required string EmploymentType { get; set; }
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
