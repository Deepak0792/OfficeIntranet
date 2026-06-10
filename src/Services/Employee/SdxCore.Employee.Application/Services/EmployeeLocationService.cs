using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeLocationService : IEmployeeLocationService
{
    private readonly IEmployeeLocationRepository _repository;

    public EmployeeLocationService(IEmployeeLocationRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeLocationResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeLocation, EmployeeLocationResponse>(e)).ToList();
    }

    public async Task<EmployeeLocationResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeLocation, EmployeeLocationResponse>(entity);
    }

    public async Task<EmployeeLocationResponse> AddAsync(Guid employeeId, CreateEmployeeLocationRequest request, CancellationToken cancellationToken = default)
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
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeLocationResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeLocationRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee location not found");

        entity.StartDate = request.StartDate;
        entity.EndDate = request.EndDate;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated entity");
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = entities.FirstOrDefault(x => x.Id == id);
        if (target == null) return false;

        foreach (var e in entities.Where(x => x.IsPrimaryLocation))
        {
            e.IsPrimaryLocation = false;
            _repository.Update(e);
        }

        target.IsPrimaryLocation = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
