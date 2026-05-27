namespace SdxCore.Employee.Domain.DTOs.Request;

public class AddEmployeeAddressRequest
{
    public string AddressType { get; set; } = string.Empty;
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string City { get; set; } = string.Empty;
    public short CountryId { get; set; }
}

public class AddEmployeeDocumentRequest
{
    public short DocumentTypeId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
}
