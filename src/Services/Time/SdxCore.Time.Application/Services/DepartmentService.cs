using SdxCore.Time.Domain.DTOs;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Services;
using SdxCore.Time.Domain.Interfaces.Repositories;
using System;
using SdxCore.Time.Application.Helpers;
using SdxCore.Common.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class DepartmentService : IDepartmentService 
{
    private readonly IDepartmentRepository _repository;
    
    public DepartmentService(IDepartmentRepository repository) 
    {
        _repository = repository;
    }
    
            public async Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(e => SimpleMapper.Map<Department, DepartmentDto>(e));
    }

    public async Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var d = await _repository.GetByIdAsync(id, cancellationToken);
        if (d == null) return null;
        return new DepartmentDto {
            Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
        };
    }
    
    public async Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = new Department {
            DepartmentCode = dto.DepartmentCode, DepartmentName = dto.DepartmentName,
            ParentDepartmentId = dto.ParentDepartmentId, Description = dto.Description,
            IsActive = true, CreatedAt = DateTime.UtcNow
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;
        
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
    
    public async Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.IsActive = false; // Soft delete
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}


