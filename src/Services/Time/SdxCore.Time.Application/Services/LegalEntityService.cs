using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.LegalEntity.Request;
using SdxCore.Time.Application.DTOs.LegalEntity.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class LegalEntityService(
    ILegalEntityRepository repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    ITimeUnitOfWork unitOfWork) : ILegalEntityService
{
    private readonly ILegalEntityRepository _repository = repository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(LegalEntity), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return PropertyMapper.MapList<LegalEntity, LegalEntityResponse>(entities);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<LegalEntityResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(LegalEntity), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity is null) return null;
            return PropertyMapper.Map<LegalEntity, LegalEntityResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateLegalEntityRequest, LegalEntity>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateLegalEntityRequest request, CancellationToken cancellationToken = default)
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