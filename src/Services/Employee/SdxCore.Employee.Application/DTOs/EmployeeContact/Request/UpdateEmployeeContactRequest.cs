namespace SdxCore.Employee.Application.DTOs.EmployeeContact.Request;

public class UpdateEmployeeContactRequest
{
    /// <summary>Lookup code from shared.StatusLookup under group CONTACT_TYPE (e.g. PHONE, EMAIL).</summary>
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimaryContact { get; set; }
}
