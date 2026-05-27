namespace SdxCore.Employee.Domain.Entities;

public class EmployeeContact : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string ContactType { get; set; } = string.Empty;
    public string ContactValue { get; set; } = string.Empty;
    public bool IsPrimary { get; set; } = false;

    public Employee? Employee { get; set; }
}
