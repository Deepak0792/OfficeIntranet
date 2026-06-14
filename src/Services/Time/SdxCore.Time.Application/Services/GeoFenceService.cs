using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.GeoFence.Request;
using SdxCore.Time.Application.DTOs.GeoFence.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class GeoFenceService(
    IGeoFenceRepository repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    ITimeUnitOfWork unitOfWork) : IGeoFenceService
{
    private readonly IGeoFenceRepository _repository = repository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<GeoFenceResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(GeoFence), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return PropertyMapper.MapList<GeoFence, GeoFenceResponse>(entities);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<GeoFenceResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(GeoFence), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity is null) return null;
            return PropertyMapper.Map<GeoFence, GeoFenceResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<GeoFenceResponse> CreateAsync(CreateGeoFenceRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateGeoFenceRequest, GeoFence>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateGeoFenceRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        PropertyMapper.Patch(request, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        PropertyMapper.Patch(request, entity);
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
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