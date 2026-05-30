using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeDocumentResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DocumentTypeId { get; set; }
    public string? DocumentTypeName { get; set; }
    public string? FileName { get; set; }
    public string? OriginalFileName { get; set; }
    public string? FileExtension { get; set; }
    public string? MimeType { get; set; }
    public int? FileSizeInBytes { get; set; }
    public string? FileUrl { get; set; }
    public string? DocumentNumber { get; set; }
    public DateOnly? IssuedDate { get; set; }
    public DateOnly? ExpiryDate { get; set; }
    public string? Remarks { get; set; }
    public DateTime UploadedAt { get; set; }
    public bool IsVerified { get; set; }
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public int? WorkflowInstanceId { get; set; }
    public bool IsActive { get; set; }
}
