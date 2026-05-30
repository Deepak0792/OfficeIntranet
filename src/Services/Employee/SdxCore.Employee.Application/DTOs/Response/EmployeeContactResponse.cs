namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeContactResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimary { get; set; }
    public bool IsActive { get; set; }
}
