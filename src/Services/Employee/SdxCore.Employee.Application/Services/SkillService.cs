using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class SkillService : ISkillService
{
    private readonly ISkillRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    private readonly IEmployeeUnitOfWork _unitOfWork;

    public SkillService(
        ISkillRepository repository, 
        ICacheService cacheService, 
        ICacheKeyBuilder cacheKeyBuilder,
        IEmployeeUnitOfWork unitOfWork)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<SkillResponse>> GetAllAsync(string? category = null, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Skill", "All");

        var items = await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => PropertyMapper.Map<Skill, SkillResponse>(e)).ToList();
        }, CacheOptions.Default, cancellationToken);

        if (!string.IsNullOrEmpty(category) && items != null)
        {
            return items.Where(s => s.SkillCategory == category);
        }

        return items ?? new List<SkillResponse>();
    }

    public async Task<SkillResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Skill", id.ToString());

        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;

            return PropertyMapper.Map<Skill, SkillResponse>(entity);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<SkillResponse> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateSkillRequest, Skill>(request);
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Skill, SkillResponse>(created);
    }

    public async Task<SkillResponse> UpdateAsync(Guid id, UpdateSkillRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) throw new KeyNotFoundException($"Skill with ID {id} not found.");

        entity.SkillName = request.SkillName;
        entity.SkillCategory = request.SkillCategory;
        entity.Description = request.Description;

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Skill, SkillResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
