using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeLocationResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LocationId { get; set; }
    public string? LocationName { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
