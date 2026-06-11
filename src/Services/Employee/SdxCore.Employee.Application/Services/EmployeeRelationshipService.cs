using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeRelationshipService : IEmployeeRelationshipService
{
    private readonly IEmployeeRelationshipRepository _repository;
    private readonly IEmployeeUnitOfWork _unitOfWork;

    public EmployeeRelationshipService(
       IEmployeeRelationshipRepository repository,
       IEmployeeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }
    public async Task<IEnumerable<EmployeeRelationshipResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.ChildEmployeeId == employeeId, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(e)).ToList();
    }

    public async Task<EmployeeRelationshipResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(entity);
    }

    public async Task<IEnumerable<EmployeeRelationshipResponse>> GetDirectReportsAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.ParentEmployeeId == employeeId && x.RelationshipType == "DIRECT_MANAGER" && x.IsActive, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(e)).ToList();
    }

    public async Task<EmployeeRelationshipResponse?> GetManagerAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.ChildEmployeeId == employeeId && x.RelationshipType == "DIRECT_MANAGER" && x.IsPrimaryRelationship && x.IsActive, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeRelationship, EmployeeRelationshipResponse>(entity);
    }

    public async Task<EmployeeRelationshipResponse> AddAsync(Guid employeeId, CreateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default)
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
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(request.ChildEmployeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeRelationshipResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee relationship not found");

        entity.RelationshipType = request.RelationshipType;
        entity.DepartmentId = request.DepartmentId;
        entity.EffectiveFrom = request.EffectiveFrom;
        entity.EffectiveTo = request.EffectiveTo;

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated entity");
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.ChildEmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
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
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
