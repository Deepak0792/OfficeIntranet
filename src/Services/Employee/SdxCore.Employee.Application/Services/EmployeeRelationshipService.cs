using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeRelationshipService : IEmployeeRelationshipService
{
    private readonly IEmployeeRelationshipRepository _repository;

    public EmployeeRelationshipService(IEmployeeRelationshipRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeRelationshipResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.ChildEmployeeId == employeeId, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(e)).ToList();
    }

    public async Task<EmployeeRelationshipResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(entity);
    }
    
    public async Task<IEnumerable<EmployeeRelationshipResponse>> GetDirectReportsAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.ParentEmployeeId == employeeId && x.RelationshipType == "DIRECT_MANAGER" && x.IsActive, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(e)).ToList();
    }

    public async Task<EmployeeRelationshipResponse?> GetManagerAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.ChildEmployeeId == employeeId && x.RelationshipType == "DIRECT_MANAGER" && x.IsPrimaryRelationship && x.IsActive, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(entity);
    }

    public async Task<EmployeeRelationshipResponse> AddAsync(int employeeId, CreateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default)
    {
        if (request.ChildEmployeeId == employeeId)
        {
            throw new Exception("An employee cannot be their own manager/relationship target.");
        }

        if (request.IsPrimaryRelationship)
        {
            var existingEntities = await _repository.FindAsync(x => x.ChildEmployeeId == employeeId && x.RelationshipType == request.RelationshipType && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimaryRelationship))
            {
                e.IsPrimaryRelationship = false;
                _repository.Update(e);
            }
        }
        var entity = PropertyMapper.Map<CreateEmployeeRelationshipRequest, EmployeeRelationship>(request);
        entity.ParentEmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(request.ChildEmployeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeRelationshipResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee relationship not found");

        entity.RelationshipType = request.RelationshipType;
        entity.DepartmentId = request.DepartmentId;
        entity.EffectiveFrom = request.EffectiveFrom;
        entity.EffectiveTo = request.EffectiveTo;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated entity");
    }

    public async Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.ChildEmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = entities.FirstOrDefault(x => x.Id == id);
        if (target == null) return false;

        foreach (var e in entities.Where(x => x.IsPrimaryRelationship && x.RelationshipType == target.RelationshipType))
        {
            e.IsPrimaryRelationship = false;
            _repository.Update(e);
        }

        target.IsPrimaryRelationship = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
