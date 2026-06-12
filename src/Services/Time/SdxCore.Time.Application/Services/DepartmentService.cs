using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.DTOs.Department.Request;
using SdxCore.Time.Application.DTOs.Department.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Services;

public class DepartmentService : IDepartmentService
{
    private readonly IDepartmentRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    private readonly ITimeUnitOfWork _unitOfWork;

    public DepartmentService(
        IDepartmentRepository repository,
        ICacheService cacheService, 
        ICacheKeyBuilder cacheKeyBuilder,
        ITimeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
        _unitOfWork = unitOfWork;
    }
    
    public async Task<IEnumerable<DepartmentResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Department), "all");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => PropertyMapper.Map<Department, DepartmentResponse>(e));
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DepartmentResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey(nameof(Department), id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var d = await _repository.GetByIdAsync(id, ct);
            if (d == null) return null;

            return PropertyMapper.Map<Department, DepartmentResponse>(d);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<DepartmentResponse> CreateAsync(CreateDepartmentRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateDepartmentRequest, Department>(dto);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateDepartmentRequest dto, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;

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

    public async Task<IEnumerable<DepartmentResponse>> GetTreeAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var allActive = await _repository.FindAsync(x => x.IsActive, cancellationToken);
            var dtos = allActive.Select(e => PropertyMapper.Map<Department, DepartmentResponse>(e)).ToList();

            var lookup = dtos.ToLookup(x => x.ParentDepartmentId);
            foreach (var dto in dtos)
            {
                var children = lookup[dto.Id].ToList();
                if (children.Any()) dto.Children = children;
            }

            return lookup[null].ToList();
        }
        catch (Exception)
        {
            throw;
        }
    }

    public async Task<IEnumerable<DepartmentResponse>> GetChildrenAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var children = await _repository.FindAsync(x => x.ParentDepartmentId == id && x.IsActive, cancellationToken);
        return children.Select(e => PropertyMapper.Map<Department, DepartmentResponse>(e));
    }

    public async Task<IEnumerable<DepartmentResponse>> GetAncestorsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ancestors = new List<DepartmentResponse>();
        var currentId = id;

        while (true)
        {
            var entity = await _repository.GetByIdAsync(currentId, cancellationToken);
            if (entity == null || entity.ParentDepartmentId == null) break;

            var parent = await _repository.GetByIdAsync(entity.ParentDepartmentId.Value, cancellationToken);
            if (parent == null || !parent.IsActive) break;

            ancestors.Add(PropertyMapper.Map<Department, DepartmentResponse>(parent));
            currentId = parent.Id;
        }

        return ancestors;
    }

    public async Task<bool> UpdateParentAsync(Guid id, UpdateParentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        if (request.ParentId == id) throw new InvalidOperationException("A department cannot be its own parent.");

        entity.ParentDepartmentId = request.ParentId;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}