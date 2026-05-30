using SdxCore.Common.Caching;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Application.Interfaces.Services;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Repositories;

namespace SdxCore.Time.Application.Services;

public class LegalEntityService : ILegalEntityService 
{
    private readonly ILegalEntityRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public LegalEntityService(ILegalEntityRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }
    
            public async Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("legalentity", "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => SimpleMapper.Map<LegalEntity, LegalEntityResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<LegalEntityResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("legalentity", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return SimpleMapper.Map<LegalEntity, LegalEntityResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }
    
    public async Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateLegalEntityRequest, LegalEntity>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(short id, UpdateLegalEntityRequest dto, CancellationToken cancellationToken = default) 
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


