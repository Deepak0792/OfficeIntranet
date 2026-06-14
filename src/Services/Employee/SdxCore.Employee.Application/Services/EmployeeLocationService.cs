using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeLocation.Request;
using SdxCore.Employee.Application.DTOs.EmployeeLocation.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeLocationService(
   IEmployeeLocationRepository repository,
   IEmployeeUnitOfWork unitOfWork) : IEmployeeLocationService
{
    private readonly IEmployeeLocationRepository _repository = repository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeLocationResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return PropertyMapper.MapList<EmployeeLocation, EmployeeLocationResponse>(entities);
    }

    public async Task<EmployeeLocationResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity is null) return null;

        return PropertyMapper.Map<EmployeeLocation, EmployeeLocationResponse>(entity);
    }

    public async Task<EmployeeLocationResponse> CreateAsync(Guid employeeId, CreateEmployeeLocationRequest request, CancellationToken cancellationToken = default)
    {
        if (request.IsPrimaryLocation)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimaryLocation))
            {
                e.IsPrimaryLocation = false;
                _repository.Update(e);
            }
        }

        var entity = PropertyMapper.Map<CreateEmployeeLocationRequest, EmployeeLocation>(request);
        entity.Id = Guid.NewGuid();
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken)
            ?? throw new InvalidOperationException("Failed to retrieve created entity");
    }

    public async Task<EmployeeLocationResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeLocationRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee location not found");

        PropertyMapper.Patch(request, entity);
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new InvalidOperationException("Failed to retrieve updated entity");
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

    public async Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = entities.FirstOrDefault(x => x.Id == id);
        if (target is null) return false;

        foreach (var e in entities.Where(x => x.IsPrimaryLocation))
        {
            e.IsPrimaryLocation = false;
            _repository.Update(e);
        }

        target.IsPrimaryLocation = true;
        _repository.Update(target);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
