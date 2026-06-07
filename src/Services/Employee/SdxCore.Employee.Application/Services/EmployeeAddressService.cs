using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeAddressService : IEmployeeAddressService
{
    private readonly IEmployeeAddressRepository _repository;

    public EmployeeAddressService(IEmployeeAddressRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeAddressResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        return entities.Select(e => PropertyMapper.Map<EmployeeAddress, EmployeeAddressResponse>(e)).ToList();      
    }

    public async Task<EmployeeAddressResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeAddress, EmployeeAddressResponse>(entity);
    }

    public async Task<EmployeeAddressResponse> AddAsync(int employeeId, CreateEmployeeAddressRequest request, CancellationToken cancellationToken = default)
    {
        if (request.IsPrimary)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimaryAddress))
            {
                e.IsPrimaryAddress = false;
                _repository.Update(e);
            }
        }

        var entity = PropertyMapper.Map<CreateEmployeeAddressRequest, EmployeeAddress>(request);
        entity.EmployeeId = employeeId;
        entity.IsVerified = false;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeAddressResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeAddressRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee address not found");

        entity.AddressLine1 = request.AddressLine1;
        entity.AddressLine2 = request.AddressLine2;
        entity.Landmark = request.Landmark;
        entity.City = request.City;
        entity.StateProvince = request.StateProvince;
        entity.PostalCode = request.PostalCode;
        entity.CountryId = request.CountryId;
        entity.RegionId = request.RegionId;

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

    public async Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = entities.FirstOrDefault(x => x.Id == id);
        if (target == null) return false;

        foreach (var e in entities.Where(x => x.IsPrimaryAddress))
        {
            e.IsPrimaryAddress = false;
            _repository.Update(e);
        }

        target.IsPrimaryAddress = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
