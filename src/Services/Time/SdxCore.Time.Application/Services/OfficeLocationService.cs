using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using System;
using SdxCore.Common.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class OfficeLocationService : IOfficeLocationService 
{
    private readonly IOfficeLocationRepository _repository;
    
    public OfficeLocationService(IOfficeLocationRepository repository) 
    {
        _repository = repository;
    }
    
        public async Task<PagedResponse<IEnumerable<OfficeLocationDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {
        var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var dtos = result.Items.Select(e => SimpleMapper.Map<OfficeLocation, OfficeLocationDto>(e));
        return new PagedResponse<IEnumerable<OfficeLocationDto>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
    }

    public async Task<OfficeLocationDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<OfficeLocation, OfficeLocationDto>(entity);
    }
    
    public async Task<OfficeLocationDto> CreateAsync(CreateOfficeLocationDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateOfficeLocationDto, OfficeLocation>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, UpdateOfficeLocationDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        SimpleMapper.MapProperties(dto, entity);
        
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

