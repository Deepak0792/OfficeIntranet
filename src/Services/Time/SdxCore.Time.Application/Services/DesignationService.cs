using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.Designation.Request;
using SdxCore.Time.Application.DTOs.Designation.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class DesignationService : IDesignationService
{
    private readonly IDesignationRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork;

    public DesignationService(
        IDesignationRepository repository, 
        ICacheService cacheService, 
        ICacheKeyBuilder cacheKeyBuilder,
        ITimeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
        _unitOfWork = unitOfWork;
    }
    
    public async Task<IEnumerable<DesignationResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Designation), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => PropertyMapper.Map<Designation, DesignationResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DesignationResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Designation), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return PropertyMapper.Map<Designation, DesignationResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DesignationResponse> CreateAsync(CreateDesignationRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateDesignationRequest, Designation>(dto);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateDesignationRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        PropertyMapper.MapProperties(dto, entity);

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}