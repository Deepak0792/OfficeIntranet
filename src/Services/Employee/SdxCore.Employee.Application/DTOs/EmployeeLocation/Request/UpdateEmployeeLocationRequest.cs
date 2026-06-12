namespace SdxCore.Employee.Application.DTOs.EmployeeLocation.Request;

public class UpdateEmployeeLocationRequest
{
    /// <summary>Cross-schema FK to time.OfficeLocation. Allows reassigning the location.</summary>
    public Guid LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}