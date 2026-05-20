using SdxCore.Time.Domain.DTOs;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Services;
using SdxCore.Time.Domain.Interfaces.Repositories;
using System;
using SdxCore.Common.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class GeoFenceService : IGeoFenceService 
{
    private readonly IGeoFenceRepository _repository;
    
    public GeoFenceService(IGeoFenceRepository repository) 
    {
        _repository = repository;
    }
    
            public async Task<IEnumerable<GeoFenceDto>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(e => SimpleMapper.Map<GeoFence, GeoFenceDto>(e));
    }

    public async Task<GeoFenceDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<GeoFence, GeoFenceDto>(entity);
    }
    
    public async Task<GeoFenceDto> CreateAsync(CreateGeoFenceDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateGeoFenceDto, GeoFence>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, UpdateGeoFenceDto dto, CancellationToken cancellationToken = default) 
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


