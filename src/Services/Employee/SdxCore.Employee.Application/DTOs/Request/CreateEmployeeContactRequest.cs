namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeContactRequest
{
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimary { get; set; }
}
