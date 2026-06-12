namespace SdxCore.Employee.Application.DTOs.EmployeeContact.Request;

public class CreateEmployeeContactRequest
{
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimaryContact { get; set; }
}
