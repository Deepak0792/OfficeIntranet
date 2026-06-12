namespace SdxCore.Employee.Application.DTOs.EmployeeLocation.Response;

public class EmployeeLocationResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid LocationId { get; set; }
    public string? LocationName { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
