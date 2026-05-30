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

public class EmployeeContactService : IEmployeeContactService
{
    private readonly IEmployeeContactRepository _repository;

    public EmployeeContactService(IEmployeeContactRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeContactResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return entities.Select(e => new EmployeeContactResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            ContactType = e.ContactType,
            ContactValue = e.ContactValue,
            IsPrimary = e.IsPrimary,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeContactResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeContactResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            ContactType = entity.ContactType,
            ContactValue = entity.ContactValue,
            IsPrimary = entity.IsPrimary,
            IsActive = entity.IsActive
        };
    }

    public async Task<EmployeeContactResponse> AddAsync(int employeeId, AddEmployeeContactRequest request, CancellationToken cancellationToken = default)
    {
        if (request.IsPrimary)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.ContactType == request.ContactType && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimary))
            {
                e.IsPrimary = false;
                _repository.Update(e);
            }
        }

        var entity = new EmployeeContact
        {
            EmployeeId = employeeId,
            ContactType = request.ContactType,
            ContactValue = request.ContactValue,
            IsPrimary = request.IsPrimary,
            IsActive = true
        };

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeContactResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeContactRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee contact not found");

        entity.ContactValue = request.ContactValue;

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

        foreach (var e in entities.Where(x => x.IsPrimary && x.ContactType == target.ContactType))
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
