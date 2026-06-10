using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeLocationRequest
{
    public Guid LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}