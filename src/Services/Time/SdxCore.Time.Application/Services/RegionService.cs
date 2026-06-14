using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.Region.Request;
using SdxCore.Time.Application.DTOs.Region.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class RegionService(
    IRegionRepository repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    ITimeUnitOfWork unitOfWork) : IRegionService
{
    private readonly IRegionRepository _repository = repository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<RegionResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Region), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return PropertyMapper.MapList<Region, RegionResponse>(entities);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<RegionResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Region), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity is null) return null;
            return PropertyMapper.Map<Region, RegionResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<RegionResponse> CreateAsync(CreateRegionRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateRegionRequest, Region>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateRegionRequest request, CancellationToken cancellationToken = default)
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

    public async Task<IEnumerable<RegionResponse>> GetByCountryIdAsync(Guid countryId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.CountryId == countryId && x.IsActive, cancellationToken);
        return entities.Select(e => PropertyMapper.Map<Region, RegionResponse>(e));
    }

    public async Task<IEnumerable<RegionResponse>> GetTreeAsync(CancellationToken cancellationToken = default)
    {
        var allActive = await _repository.FindAsync(x => x.IsActive, cancellationToken);
        var dtos = allActive.Select(e => PropertyMapper.Map<Region, RegionResponse>(e)).ToList();

        var lookup = dtos.ToLookup(x => x.ParentRegionId);
        foreach (var dto in dtos)
        {
            var children = lookup[dto.Id].ToList();
            if (children.Count > 0) dto.Children = children;
        }

        return [.. lookup[null]];
    }

    public async Task<IEnumerable<RegionResponse>> GetChildrenAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var children = await _repository.FindAsync(x => x.ParentRegionId == id && x.IsActive, cancellationToken);
        return children.Select(e => PropertyMapper.Map<Region, RegionResponse>(e));
    }

    public async Task<IEnumerable<RegionResponse>> GetAncestorsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ancestors = new List<RegionResponse>();
        var currentId = id;

        while (true)
        {
            var entity = await _repository.GetByIdAsync(currentId, cancellationToken);
            if (entity == null || entity.ParentRegionId == null) break;

            var parent = await _repository.GetByIdAsync(entity.ParentRegionId.Value, cancellationToken);
            if (parent == null || !parent.IsActive) break;

            ancestors.Add(PropertyMapper.Map<Region, RegionResponse>(parent));
            currentId = parent.Id;
        }

        return ancestors;
    }

    public async Task<bool> UpdateParentAsync(Guid id, UpdateParentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;

        // Basic circular dependency check can be added here
        if (request.ParentId == id) throw new InvalidOperationException("A region cannot be its own parent.");

        entity.ParentRegionId = request.ParentId;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}