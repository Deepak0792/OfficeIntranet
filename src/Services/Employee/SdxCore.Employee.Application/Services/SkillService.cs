using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.Skill.Request;
using SdxCore.Employee.Application.DTOs.Skill.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class SkillService(
    ISkillRepository repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    IEmployeeUnitOfWork unitOfWork) : ISkillService
{
    private readonly ISkillRepository _repository = repository;
    private readonly ICacheService _cacheService = cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder = cacheKeyBuilder;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<SkillResponse>> GetAllAsync(string? category = null, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Skill", "All");

        var items = await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return PropertyMapper.MapList<Skill, SkillResponse>(entities);
        }, CacheOptions.Default, cancellationToken);

        if (!string.IsNullOrEmpty(category) && items is not null)
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
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Skill, SkillResponse>(created);
    }

    public async Task<SkillResponse> UpdateAsync(Guid id, UpdateSkillRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Skill with ID {id} not found.");

        PropertyMapper.Patch(request, entity);
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Skill, SkillResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Skill with ID {id} not found.");

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
