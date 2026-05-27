using SdxCore.Common.Caching;
using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Services;
using SdxCore.Time.Domain.Interfaces.Repositories;
using System;
using SdxCore.Time.Application.Helpers;
using SdxCore.Common.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class DepartmentService : IDepartmentService 
{
    private readonly IDepartmentRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public DepartmentService(IDepartmentRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }
    
            public async Task<IEnumerable<DepartmentResponse>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("department", "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => SimpleMapper.Map<Department, DepartmentResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DepartmentResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default) 
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("department", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var d = await _repository.GetByIdAsync(id, ct);
            if (d == null) return null;
            return new DepartmentResponse {
                Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
                ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
            };
        }, CacheOptions.StaticMasterData, cancellationToken);
    }
    
    public async Task<DepartmentResponse> CreateAsync(CreateDepartmentRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = new Department {
            DepartmentCode = dto.DepartmentCode, DepartmentName = dto.DepartmentName,
            ParentDepartmentId = dto.ParentDepartmentId, Description = dto.Description,
            IsActive = true, CreatedAt = DateTime.UtcNow
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(short id, UpdateDepartmentRequest dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;
        
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

    public async Task<IEnumerable<DepartmentResponse>> GetTreeAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var allActive = await _repository.FindAsync(x => x.IsActive, cancellationToken);
            var dtos = allActive.Select(e => SimpleMapper.Map<Department, DepartmentResponse>(e)).ToList();

            var lookup = dtos.ToLookup(x => x.ParentDepartmentId);
            foreach (var dto in dtos)
            {
                var children = lookup[dto.Id].ToList();
                if (children.Any()) dto.Children = children;
            }

            return lookup[null].ToList();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<IEnumerable<DepartmentResponse>> GetChildrenAsync(short id, CancellationToken cancellationToken = default)
    {
        var children = await _repository.FindAsync(x => x.ParentDepartmentId == id && x.IsActive, cancellationToken);
        return children.Select(e => SimpleMapper.Map<Department, DepartmentResponse>(e));
    }

    public async Task<IEnumerable<DepartmentResponse>> GetAncestorsAsync(short id, CancellationToken cancellationToken = default)
    {
        var ancestors = new List<DepartmentResponse>();
        var currentId = id;
        
        while (true)
        {
            var entity = await _repository.GetByIdAsync(currentId, cancellationToken);
            if (entity == null || entity.ParentDepartmentId == null) break;
            
            var parent = await _repository.GetByIdAsync(entity.ParentDepartmentId.Value, cancellationToken);
            if (parent == null || !parent.IsActive) break;
            
            ancestors.Add(SimpleMapper.Map<Department, DepartmentResponse>(parent));
            currentId = parent.Id;
        }
        
        return ancestors;
    }

    public async Task<bool> UpdateParentAsync(short id, UpdateParentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        if (request.ParentId == id) throw new InvalidOperationException("A department cannot be its own parent.");
        
        entity.ParentDepartmentId = request.ParentId;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}



