namespace SdxCore.Employee.Application.DTOs.Request;
public class UpdateEmployeeDocumentRequest
{
    public string? DocumentNumber { get; set; }
    public DateOnly? IssuedDate { get; set; }
    public DateOnly? ExpiryDate { get; set; }
    public string? Remarks { get; set; }
}