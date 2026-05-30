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
        
        return entities.Select(e => new EmployeeAddressResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            AddressType = e.AddressType,
            AddressLine1 = e.AddressLine1,
            AddressLine2 = e.AddressLine2,
            Landmark = e.Landmark,
            City = e.City,
            StateProvince = e.StateProvince,
            PostalCode = e.PostalCode,
            CountryId = e.CountryId,
            RegionId = e.RegionId,
            IsPrimary = e.IsPrimary,
            WorkflowInstanceId = e.WorkflowInstanceId,
            IsVerified = e.IsVerified,
            VerifiedByEmployeeId = e.VerifiedByEmployeeId,
            VerifiedAt = e.VerifiedAt,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeAddressResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeAddressResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            AddressType = entity.AddressType,
            AddressLine1 = entity.AddressLine1,
            AddressLine2 = entity.AddressLine2,
            Landmark = entity.Landmark,
            City = entity.City,
            StateProvince = entity.StateProvince,
            PostalCode = entity.PostalCode,
            CountryId = entity.CountryId,
            RegionId = entity.RegionId,
            IsPrimary = entity.IsPrimary,
            WorkflowInstanceId = entity.WorkflowInstanceId,
            IsVerified = entity.IsVerified,
            VerifiedByEmployeeId = entity.VerifiedByEmployeeId,
            VerifiedAt = entity.VerifiedAt,
            IsActive = entity.IsActive
        };
    }

    public async Task<EmployeeAddressResponse> AddAsync(int employeeId, AddEmployeeAddressRequest request, CancellationToken cancellationToken = default)
    {
        if (request.IsPrimary)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimary))
            {
                e.IsPrimary = false;
                _repository.Update(e);
            }
        }

        var entity = new EmployeeAddress
        {
            EmployeeId = employeeId,
            AddressType = request.AddressType,
            AddressLine1 = request.AddressLine1,
            AddressLine2 = request.AddressLine2,
            Landmark = request.Landmark,
            City = request.City,
            StateProvince = request.StateProvince,
            PostalCode = request.PostalCode,
            CountryId = request.CountryId,
            RegionId = request.RegionId,
            IsPrimary = request.IsPrimary,
            IsVerified = false,
            IsActive = true
        };

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

        foreach (var e in entities.Where(x => x.IsPrimary))
        {
            e.IsPrimary = false;
            _repository.Update(e);
        }

        target.IsPrimary = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
