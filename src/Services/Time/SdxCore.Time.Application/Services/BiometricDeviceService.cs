using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.SharedKernel.Persistence;
using SdxCore.Time.Application.Contracts.Services;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;
using SdxCore.Time.Domain;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;

namespace SdxCore.Time.Application.Services;

public class BiometricDeviceService : IBiometricDeviceService
{
    private readonly IBiometricDeviceRepository _repository;
    private readonly ITimeUnitOfWork _unitOfWork;
    //private readonly ICacheService _cacheService;
    //private readonly ICacheKeyBuilder _cacheKeyBuilder;
    //
    public BiometricDeviceService(
        IBiometricDeviceRepository repository,
        ITimeUnitOfWork unitOfWork)//, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        //_cacheService = cacheService;
        //_cacheKeyBuilder = cacheKeyBuilder;
    }

    public async Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        //var cacheKey = _cacheKeyBuilder.BuildKey("biometricdevice", $"page:{filter.PageNumber}:{filter.PageSize}");
        //return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        //{
        //    var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);
        //    var dtos = result.Items.Select(e => PropertyMapper.Map<BiometricDevice, BiometricDeviceResponse>(e));
        //    return new PagedResponse<IEnumerable<BiometricDeviceResponse>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
        //}, CacheOptions.StaticMasterData, cancellationToken);

        var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var dtos = result.Items.Select(e => PropertyMapper.Map<BiometricDevice, BiometricDeviceResponse>(e));
        return new PagedResponse<IEnumerable<BiometricDeviceResponse>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
    }

    public async Task<BiometricDeviceResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        //var cacheKey = _cacheKeyBuilder.BuildKey("biometricdevice", id.ToString());
        //return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        //{
        //    var entity = await _repository.GetByIdAsync(id, ct);
        //    if (entity == null) return null;
        //    return PropertyMapper.Map<BiometricDevice, BiometricDeviceResponse>(entity);
        //}, CacheOptions.StaticMasterData, cancellationToken);
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return PropertyMapper.Map<BiometricDevice, BiometricDeviceResponse>(entity);
    }

    public async Task<BiometricDeviceResponse> CreateAsync(CreateBiometricDeviceRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateBiometricDeviceRequest, BiometricDevice>(dto);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken = default)
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

    public async Task<bool> SyncDeviceAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null || !entity.IsActive) return false;

        entity.LastSyncAt = DateTime.UtcNow;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}