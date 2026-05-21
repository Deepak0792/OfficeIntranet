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

public class BiometricDeviceService : IBiometricDeviceService 
{
    private readonly IBiometricDeviceRepository _repository;
    
    public BiometricDeviceService(IBiometricDeviceRepository repository) 
    {
        _repository = repository;
    }
    
        public async Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {
        var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var dtos = result.Items.Select(e => SimpleMapper.Map<BiometricDevice, BiometricDeviceResponse>(e));
        return new PagedResponse<IEnumerable<BiometricDeviceResponse>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
    }

    public async Task<BiometricDeviceResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<BiometricDevice, BiometricDeviceResponse>(entity);
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


