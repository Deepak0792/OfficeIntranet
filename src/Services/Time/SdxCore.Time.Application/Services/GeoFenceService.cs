using SdxCore.Common.Caching;
using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
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
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public GeoFenceService(IGeoFenceRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }
    
            public async Task<IEnumerable<GeoFenceResponse>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("geofence", "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => SimpleMapper.Map<GeoFence, GeoFenceResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<GeoFenceResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("geofence", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return SimpleMapper.Map<GeoFence, GeoFenceResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }
    
    public async Task<GeoFenceResponse> CreateAsync(CreateGeoFenceRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateGeoFenceRequest, GeoFence>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(short id, UpdateGeoFenceRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        SimpleMapper.MapProperties(dto, entity);
        
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
    
    public async Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<GeoFenceResponse?> CheckGeoFenceAsync(GeoFenceCheckRequest request, CancellationToken cancellationToken = default)
    {
        var allFences = await _repository.FindAsync(x => x.IsActive, cancellationToken);
        
        // Simple distance-based logic (mock implementation for architecture)
        // In reality, this would use spatial querying like NetTopologySuite or Haversine formula
        var matched = allFences.FirstOrDefault(x => 
            Math.Abs(x.Latitude - request.Latitude) < 0.01m && 
            Math.Abs(x.Longitude - request.Longitude) < 0.01m);
            
        if (matched == null) return null;
        return SimpleMapper.Map<GeoFence, GeoFenceResponse>(matched);
    }
}



