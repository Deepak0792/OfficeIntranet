using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeContact.Request;
using SdxCore.Employee.Application.DTOs.EmployeeContact.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeContactService(
   IEmployeeContactRepository repository,
   IEmployeeUnitOfWork unitOfWork) : IEmployeeContactService
{
    private readonly IEmployeeContactRepository _repository = repository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeContactResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return PropertyMapper.MapList<EmployeeContact, EmployeeContactResponse>(entities);
    }

    public async Task<EmployeeContactResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeContact, EmployeeContactResponse>(entity);
    }

    public async Task<EmployeeContactResponse> CreateAsync(Guid employeeId, CreateEmployeeContactRequest request, CancellationToken cancellationToken = default)
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
        entity.Id = Guid.NewGuid();
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<EmployeeContactResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeContactRequest request, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee contact not found");

        PropertyMapper.Patch(request, entity);
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
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
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
