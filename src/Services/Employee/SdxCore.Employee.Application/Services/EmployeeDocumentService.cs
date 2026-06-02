using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

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

        return entities.Select(e => PropertyMapper.Map<EmployeeDocument, EmployeeDocumentResponse>(e)).ToList();
    }

    public async Task<EmployeeDocumentResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeDocument, EmployeeDocumentResponse>(entity);
    }

    public async Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(int employeeId, int days, CancellationToken cancellationToken = default)
    {
        var targetDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(days));
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.ExpiryDate.HasValue && x.ExpiryDate.Value <= targetDate && x.IsActive, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeDocument, EmployeeDocumentResponse>(e)).ToList();
    }

    public async Task<EmployeeDocumentResponse> AddAsync(int employeeId, CreateEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeDocumentRequest, EmployeeDocument>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) 
            ?? throw new Exception("Failed to retrieve created entity");
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
