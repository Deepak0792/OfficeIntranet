namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeContactRequest
{
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimary { get; set; }
}

public class UpdateEmployeeContactRequest
{
    public string ContactValue { get; set; } = null!;
}
