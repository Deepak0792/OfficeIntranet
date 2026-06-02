namespace SdxCore.Employee.Application.DTOs.Request;

public class UpdateEmployeeLegalEntityRequest
{
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}