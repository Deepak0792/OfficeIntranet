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

public class EmployeeLocationService : IEmployeeLocationService
{
    private readonly IEmployeeLocationRepository _repository;

    public EmployeeLocationService(IEmployeeLocationRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeLocationResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return entities.Select(e => new EmployeeLocationResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            LocationId = e.LocationId,
            IsPrimaryLocation = e.IsPrimaryLocation,
            StartDate = e.StartDate,
            EndDate = e.EndDate,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeLocationResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeLocationResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            LocationId = entity.LocationId,
            IsPrimaryLocation = entity.IsPrimaryLocation,
            StartDate = entity.StartDate,
            EndDate = entity.EndDate,
            IsActive = entity.IsActive
        };
    }

    public async Task<EmployeeLocationResponse> AddAsync(int employeeId, AddEmployeeLocationRequest request, CancellationToken cancellationToken = default)
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

        var entity = new EmployeeLocation
        {
            EmployeeId = employeeId,
            LocationId = request.LocationId,
            IsPrimaryLocation = request.IsPrimaryLocation,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true
        };

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeLocationResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeLocationRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee location not found");

        entity.StartDate = request.StartDate;
        entity.EndDate = request.EndDate;

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
