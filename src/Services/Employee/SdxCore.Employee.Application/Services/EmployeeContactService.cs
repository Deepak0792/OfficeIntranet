using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeContactService : IEmployeeContactService
{
    private readonly IEmployeeContactRepository _repository;

    public EmployeeContactService(IEmployeeContactRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeContactResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeContact, EmployeeContactResponse>(e)).ToList();
    }

    public async Task<EmployeeContactResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeContact, EmployeeContactResponse>(entity);
    }

    public async Task<EmployeeContactResponse> AddAsync(Guid employeeId, CreateEmployeeContactRequest request, CancellationToken cancellationToken = default)
    {
        if (request.IsPrimaryContact)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.ContactType == request.ContactType && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimaryContact))
            {
                e.IsPrimaryContact = false;
                _repository.Update(e);
            }
        }

        var entity = PropertyMapper.Map<CreateEmployeeContactRequest, EmployeeContact>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeContactResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeContactRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee contact not found");

        entity.ContactValue = request.ContactValue;

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

        foreach (var e in entities.Where(x => x.IsPrimaryContact && x.ContactType == target.ContactType))
        {
            e.IsPrimaryContact = false;
            _repository.Update(e);
        }

        target.IsPrimaryContact = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
