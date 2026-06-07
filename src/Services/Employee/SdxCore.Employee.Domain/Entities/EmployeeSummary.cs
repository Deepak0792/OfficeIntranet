namespace SdxCore.Employee.Domain.Entities;
using System;

public class EmployeeSummary
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
    public short? PrimaryTeamId { get; set; }
    public short? PrimaryDepartmentId { get; set; }
    public short? DesignationId { get; set; }
    public short? PrimaryLocationId { get; set; }
    public short? PrimaryLegalEntityId { get; set; }
    public int? DirectManagerId { get; set; }
    public string? DirectManagerName { get; set; }
}
