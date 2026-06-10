namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeContactResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimaryContact { get; set; }
    public bool IsActive { get; set; }
}