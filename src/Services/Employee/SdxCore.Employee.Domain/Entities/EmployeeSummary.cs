namespace SdxCore.Employee.Domain.Entities;
using System;

public class EmployeeSummary
{
    public Guid EmployeeId { get; set; }
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
    public Guid? PrimaryTeamId { get; set; }
    public Guid? PrimaryDepartmentId { get; set; }
    public Guid? DesignationId { get; set; }
    public Guid? PrimaryLocationId { get; set; }
    public Guid? PrimaryLegalEntityId { get; set; }
    public Guid? DirectManagerId { get; set; }
    public string? DirectManagerName { get; set; }
}
