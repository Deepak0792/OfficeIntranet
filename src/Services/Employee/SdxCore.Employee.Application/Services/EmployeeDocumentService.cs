using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeDocumentService : IEmployeeDocumentService
{
    private readonly IEmployeeDocumentRepository _repository;

    public EmployeeDocumentService(IEmployeeDocumentRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeDocumentResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return entities.Select(e => new EmployeeDocumentResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            DocumentTypeId = e.DocumentTypeId,
            FileName = e.FileName,
            OriginalFileName = e.OriginalFileName,
            FileExtension = e.FileExtension,
            MimeType = e.MimeType,
            FileSizeInBytes = e.FileSizeInBytes,
            FileUrl = e.FileUrl,
            DocumentNumber = e.DocumentNumber,
            IssuedDate = e.IssuedDate,
            ExpiryDate = e.ExpiryDate,
            Remarks = e.Remarks,
            UploadedAt = e.UploadedAt,
            IsVerified = e.IsVerified,
            VerifiedByEmployeeId = e.VerifiedByEmployeeId,
            VerifiedAt = e.VerifiedAt,
            WorkflowInstanceId = e.WorkflowInstanceId,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeDocumentResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeDocumentResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            DocumentTypeId = entity.DocumentTypeId,
            FileName = entity.FileName,
            OriginalFileName = entity.OriginalFileName,
            FileExtension = entity.FileExtension,
            MimeType = entity.MimeType,
            FileSizeInBytes = entity.FileSizeInBytes,
            FileUrl = entity.FileUrl,
            DocumentNumber = entity.DocumentNumber,
            IssuedDate = entity.IssuedDate,
            ExpiryDate = entity.ExpiryDate,
            Remarks = entity.Remarks,
            UploadedAt = entity.UploadedAt,
            IsVerified = entity.IsVerified,
            VerifiedByEmployeeId = entity.VerifiedByEmployeeId,
            VerifiedAt = entity.VerifiedAt,
            WorkflowInstanceId = entity.WorkflowInstanceId,
            IsActive = entity.IsActive
        };
    }

    public async Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(int employeeId, int days, CancellationToken cancellationToken = default)
    {
        var targetDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(days));
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.ExpiryDate.HasValue && x.ExpiryDate.Value <= targetDate && x.IsActive, cancellationToken);
        
        return entities.Select(e => new EmployeeDocumentResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            DocumentTypeId = e.DocumentTypeId,
            FileName = e.FileName,
            OriginalFileName = e.OriginalFileName,
            FileExtension = e.FileExtension,
            MimeType = e.MimeType,
            FileSizeInBytes = e.FileSizeInBytes,
            FileUrl = e.FileUrl,
            DocumentNumber = e.DocumentNumber,
            IssuedDate = e.IssuedDate,
            ExpiryDate = e.ExpiryDate,
            Remarks = e.Remarks,
            UploadedAt = e.UploadedAt,
            IsVerified = e.IsVerified,
            VerifiedByEmployeeId = e.VerifiedByEmployeeId,
            VerifiedAt = e.VerifiedAt,
            WorkflowInstanceId = e.WorkflowInstanceId,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeDocumentResponse> AddAsync(int employeeId, AddEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = new EmployeeDocument
        {
            EmployeeId = employeeId,
            DocumentTypeId = request.DocumentTypeId,
            FileName = request.FileName,
            OriginalFileName = request.OriginalFileName,
            FileExtension = request.FileExtension,
            MimeType = request.MimeType,
            FileSizeInBytes = request.FileSizeInBytes,
            FileUrl = request.FileUrl,
            DocumentNumber = request.DocumentNumber,
            IssuedDate = request.IssuedDate,
            ExpiryDate = request.ExpiryDate,
            Remarks = request.Remarks,
            UploadedAt = DateTime.UtcNow,
            IsVerified = false,
            IsActive = true
        };

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeDocumentResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee document not found");

        entity.DocumentNumber = request.DocumentNumber;
        entity.IssuedDate = request.IssuedDate;
        entity.ExpiryDate = request.ExpiryDate;
        entity.Remarks = request.Remarks;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated entity");
    }

    public async Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
