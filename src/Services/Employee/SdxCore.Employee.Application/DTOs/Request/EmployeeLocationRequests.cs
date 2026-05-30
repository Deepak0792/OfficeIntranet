using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeLocationRequest
{
    public short LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}

public class UpdateEmployeeLocationRequest
{
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
