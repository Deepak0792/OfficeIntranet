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

public class TimeZoneMasterService : ITimeZoneMasterService 
{
    private readonly ITimeZoneMasterRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public TimeZoneMasterService(ITimeZoneMasterRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }
    
            public async Task<IEnumerable<TimeZoneMasterResponse>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("timezonemaster", "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => SimpleMapper.Map<TimeZoneMaster, TimeZoneMasterResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<TimeZoneMasterResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("timezonemaster", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return SimpleMapper.Map<TimeZoneMaster, TimeZoneMasterResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }
    
    public async Task<TimeZoneMasterResponse> CreateAsync(CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateTimeZoneMasterRequest, TimeZoneMaster>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(short id, UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default) 
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
}


