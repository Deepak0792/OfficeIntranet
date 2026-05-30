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

public class EmployeeDepartmentService : IEmployeeDepartmentService
{
    private readonly IEmployeeDepartmentRepository _repository;

    public EmployeeDepartmentService(IEmployeeDepartmentRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<EmployeeDepartmentResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        return entities.Select(e => new EmployeeDepartmentResponse
        {
            Id = e.Id,
            EmployeeId = e.EmployeeId,
            DepartmentId = e.DepartmentId,
            IsPrimaryDepartment = e.IsPrimaryDepartment,
            AllocationPercentage = e.AllocationPercentage,
            StartDate = e.StartDate,
            EndDate = e.EndDate,
            IsActive = e.IsActive
        }).ToList();
    }

    public async Task<EmployeeDepartmentResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) return null;

        return new EmployeeDepartmentResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            DepartmentId = entity.DepartmentId,
            IsPrimaryDepartment = entity.IsPrimaryDepartment,
            AllocationPercentage = entity.AllocationPercentage,
            StartDate = entity.StartDate,
            EndDate = entity.EndDate,
            IsActive = entity.IsActive
        };
    }

    private async Task ValidateAllocationPercentageAsync(int employeeId, int? currentId, decimal? additionalAllocation, CancellationToken cancellationToken)
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

    public async Task<EmployeeDepartmentResponse> AddAsync(int employeeId, AddEmployeeDepartmentRequest request, CancellationToken cancellationToken = default)
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

        var entity = new EmployeeDepartment
        {
            EmployeeId = employeeId,
            DepartmentId = request.DepartmentId,
            IsPrimaryDepartment = request.IsPrimaryDepartment,
            AllocationPercentage = request.AllocationPercentage,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true
        };

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created entity");
    }

    public async Task<EmployeeDepartmentResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default)
    {
        await ValidateAllocationPercentageAsync(employeeId, id, request.AllocationPercentage, cancellationToken);

        var entity = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (entity == null) throw new KeyNotFoundException("Employee department not found");

        entity.AllocationPercentage = request.AllocationPercentage;
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

        foreach (var e in entities.Where(x => x.IsPrimaryDepartment))
        {
            e.IsPrimaryDepartment = false;
            _repository.Update(e);
        }

        target.IsPrimaryDepartment = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
