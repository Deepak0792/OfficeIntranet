using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeDocument.Request;
using SdxCore.Employee.Application.DTOs.EmployeeDocument.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeDocumentService(
   IEmployeeDocumentRepository repository,
   IEmployeeUnitOfWork unitOfWork) : IEmployeeDocumentService
{
    private readonly IEmployeeDocumentRepository _repository = repository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeDocumentResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return PropertyMapper.MapList<EmployeeDocument, EmployeeDocumentResponse>(entities);
    }

    public async Task<EmployeeDocumentResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity is null) return null;

        return PropertyMapper.Map<EmployeeDocument, EmployeeDocumentResponse>(entity);
    }

    public async Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(Guid employeeId, int days, CancellationToken cancellationToken = default)
    {
        var targetDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(days));
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.ExpiryDate.HasValue && x.ExpiryDate.Value <= targetDate && x.IsActive, cancellationToken);

        return PropertyMapper.MapList<EmployeeDocument, EmployeeDocumentResponse>(entities);
    }

    public async Task<EmployeeDocumentResponse> CreateAsync(Guid employeeId, CreateEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeDocumentRequest, EmployeeDocument>(request);
        entity.Id = Guid.NewGuid();
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken)
            ?? throw new InvalidOperationException("Failed to retrieve created entity");
    }

    public async Task<EmployeeDocumentResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee document not found");

        PropertyMapper.Patch(request, entity);
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, entity.Id, cancellationToken)
            ?? throw new InvalidOperationException("Failed to retrieve updated entity");
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity is null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
