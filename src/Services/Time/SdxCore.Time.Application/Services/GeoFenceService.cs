using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Contracts.Services;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;

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
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(GeoFence), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => PropertyMapper.Map<GeoFence, GeoFenceResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<GeoFenceResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(GeoFence), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return PropertyMapper.Map<GeoFence, GeoFenceResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<GeoFenceResponse> CreateAsync(CreateGeoFenceRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateGeoFenceRequest, GeoFence>(dto);
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

        PropertyMapper.MapProperties(dto, entity);

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
        return PropertyMapper.Map<GeoFence, GeoFenceResponse>(matched);
    }
}



