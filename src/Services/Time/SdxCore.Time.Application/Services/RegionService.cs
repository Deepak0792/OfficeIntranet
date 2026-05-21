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

public class RegionService : IRegionService 
{
    private readonly IRegionRepository _repository;
    
    public RegionService(IRegionRepository repository) 
    {
        _repository = repository;
    }
    
            public async Task<IEnumerable<RegionResponse>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(e => SimpleMapper.Map<Region, RegionResponse>(e));
    }

    public async Task<RegionResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<Region, RegionResponse>(entity);
    }
    
    public async Task<RegionResponse> CreateAsync(CreateRegionRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateRegionRequest, Region>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(short id, UpdateRegionRequest dto, CancellationToken cancellationToken = default) 
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

    public async Task<IEnumerable<RegionResponse>> GetByCountryIdAsync(short countryId, CancellationToken cancellationToken = default)
    {
        var entities = await _repository.FindAsync(x => x.CountryId == countryId && x.IsActive, cancellationToken);
        return entities.Select(e => SimpleMapper.Map<Region, RegionResponse>(e));
    }

    public async Task<IEnumerable<RegionResponse>> GetTreeAsync(CancellationToken cancellationToken = default)
    {
        var allActive = await _repository.FindAsync(x => x.IsActive, cancellationToken);
        var dtos = allActive.Select(e => SimpleMapper.Map<Region, RegionResponse>(e)).ToList();
        
        var lookup = dtos.ToLookup(x => x.ParentRegionId);
        foreach (var dto in dtos)
        {
            var children = lookup[dto.Id].ToList();
            if (children.Any()) dto.Children = children;
        }
        
        return lookup[null].ToList();
    }

    public async Task<IEnumerable<RegionResponse>> GetChildrenAsync(short id, CancellationToken cancellationToken = default)
    {
        var children = await _repository.FindAsync(x => x.ParentRegionId == id && x.IsActive, cancellationToken);
        return children.Select(e => SimpleMapper.Map<Region, RegionResponse>(e));
    }

    public async Task<IEnumerable<RegionResponse>> GetAncestorsAsync(short id, CancellationToken cancellationToken = default)
    {
        var ancestors = new List<RegionResponse>();
        var currentId = id;
        
        while (true)
        {
            var entity = await _repository.GetByIdAsync(currentId, cancellationToken);
            if (entity == null || entity.ParentRegionId == null) break;
            
            var parent = await _repository.GetByIdAsync(entity.ParentRegionId.Value, cancellationToken);
            if (parent == null || !parent.IsActive) break;
            
            ancestors.Add(SimpleMapper.Map<Region, RegionResponse>(parent));
            currentId = parent.Id;
        }
        
        return ancestors;
    }

    public async Task<bool> UpdateParentAsync(short id, UpdateParentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        // Basic circular dependency check can be added here
        if (request.ParentId == id) throw new InvalidOperationException("A region cannot be its own parent.");
        
        entity.ParentRegionId = request.ParentId;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}



