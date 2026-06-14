using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.ScopeType.Request;
using SdxCore.Time.Application.DTOs.ScopeType.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class ScopeTypeService(
    IScopeTypeRepository repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    ITimeUnitOfWork unitOfWork) : IScopeTypeService
{
    private readonly IScopeTypeRepository _repository = repository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<ScopeTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(ScopeType), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return PropertyMapper.MapList<ScopeType, ScopeTypeResponse>(entities);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<ScopeTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(ScopeType), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity is null) return null;
            return PropertyMapper.Map<ScopeType, ScopeTypeResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<ScopeTypeResponse> CreateAsync(CreateScopeTypeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateScopeTypeRequest, ScopeType>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateScopeTypeRequest request, CancellationToken cancellationToken = default)
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
}