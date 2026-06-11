using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeDepartmentService : IEmployeeDepartmentService
{
    private readonly IEmployeeDepartmentRepository _repository;
    private readonly IEmployeeUnitOfWork _unitOfWork;

    public EmployeeDepartmentService(
       IEmployeeDepartmentRepository repository,
       IEmployeeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<EmployeeDepartmentResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);

        return entities.Select(e => PropertyMapper.Map<EmployeeDepartment, EmployeeDepartmentResponse>(e)).ToList();
    }

    public async Task<EmployeeDepartmentResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return PropertyMapper.Map<EmployeeDepartment, EmployeeDepartmentResponse>(entity);
    }

    private async Task ValidateAllocationPercentageAsync(Guid employeeId, Guid? currentId, decimal? additionalAllocation, CancellationToken cancellationToken)
    {
        var activeDepartments = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        if (currentId.HasValue)
        {
            activeDepartments = activeDepartments.Where(x => x.Id != currentId.Value);
        }

        var currentTotal = activeDepartments.Sum(x => x.AllocationPercentage ?? 0);
        if (currentTotal + (additionalAllocation ?? 0) > 100)
        {
            throw new Exception($"Total allocation percentage cannot exceed 100. Current total for other departments is {currentTotal}%.");
        }
    }

    public async Task<EmployeeDepartmentResponse> AddAsync(Guid employeeId, CreateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default)
    {
        await ValidateAllocationPercentageAsync(employeeId, null, request.AllocationPercentage, cancellationToken);

        if (request.IsPrimaryDepartment)
        {
            var existingEntities = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
            foreach (var e in existingEntities.Where(x => x.IsPrimaryDepartment))
            {
                e.IsPrimaryDepartment = false;
                _repository.Update(e);
            }
        }

        var entity = PropertyMapper.Map<CreateEmployeeDepartmentRequest, EmployeeDepartment>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeDepartmentResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default)
    {
        await ValidateAllocationPercentageAsync(employeeId, id, request.AllocationPercentage, cancellationToken);

        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee department not found");

        entity.AllocationPercentage = request.AllocationPercentage;
        entity.StartDate = request.StartDate;
        entity.EndDate = request.EndDate;

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, entity.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated entity");
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

        foreach (var e in entities.Where(x => x.IsPrimaryDepartment))
        {
            e.IsPrimaryDepartment = false;
            _repository.Update(e);
        }

        target.IsPrimaryDepartment = true;
        _repository.Update(target);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
