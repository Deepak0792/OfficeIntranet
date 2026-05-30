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

public class EmployeeLegalEntityService : IEmployeeLegalEntityService
{
    private readonly IEmployeeLegalEntityRepository _repository;

    public EmployeeLegalEntityService(IEmployeeLegalEntityRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeLegalEntityResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return entities.Select(e => new EmployeeLegalEntityResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            LegalEntityId = e.LegalEntityId,
            IsPrimary = e.IsPrimary,
            StartDate = e.StartDate,
            EndDate = e.EndDate,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeLegalEntityResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeLegalEntityResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            LegalEntityId = entity.LegalEntityId,
            IsPrimary = entity.IsPrimary,
            StartDate = entity.StartDate,
            EndDate = entity.EndDate,
            IsActive = entity.IsActive
        };
    }

    public async Task<EmployeeLegalEntityResponse> AddAsync(int employeeId, AddEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default)
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

        var entity = new EmployeeLegalEntity
        {
            EmployeeId = employeeId,
            LegalEntityId = request.LegalEntityId,
            IsPrimary = request.IsPrimary,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true
        };

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeLegalEntityResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee legal entity not found");

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
