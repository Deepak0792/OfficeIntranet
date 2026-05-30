using SdxCore.Common.Caching;
using SdxCore.Common.Models;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Application.Interfaces.Services;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Repositories;

namespace SdxCore.Time.Application.Services;

public class BiometricDeviceService : IBiometricDeviceService 
{
    private readonly IBiometricDeviceRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public BiometricDeviceService(IBiometricDeviceRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }
    
        public async Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("biometricdevice", $"page:{filter.PageNumber}:{filter.PageSize}");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);
            var dtos = result.Items.Select(e => SimpleMapper.Map<BiometricDevice, BiometricDeviceResponse>(e));
            return new PagedResponse<IEnumerable<BiometricDeviceResponse>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<BiometricDeviceResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("biometricdevice", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return SimpleMapper.Map<BiometricDevice, BiometricDeviceResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }
    
    public async Task<BiometricDeviceResponse> CreateAsync(CreateBiometricDeviceRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateBiometricDeviceRequest, BiometricDevice>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(int id, UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        SimpleMapper.MapProperties(dto, entity);
        
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
    
    public async Task<bool> ToggleStatusAsync(int id, ToggleStatusRequest request, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SyncDeviceAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null || !entity.IsActive) return false;
        
        entity.LastSyncAt = DateTime.UtcNow;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}


