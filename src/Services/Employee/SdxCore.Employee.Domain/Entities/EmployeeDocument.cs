using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDocument : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DocumentTypeId { get; set; }
    public string? FileName { get; set; }
    public string? OriginalFileName { get; set; }
    public string? FileExtension { get; set; }
    public string? MimeType { get; set; }
    public int? FileSizeInBytes { get; set; }
    public string? FileUrl { get; set; }
    public string? DocumentNumber { get; set; }
    public DateTime? IssuedDate { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public string? Remarks { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public bool IsVerified { get; set; } = false;
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public int? WorkflowInstanceId { get; set; }

    public Employee? Employee { get; set; }
    public Employee? VerifiedByEmployee { get; set; }
}
