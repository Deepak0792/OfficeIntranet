using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Common.Caching;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;

namespace SdxCore.Employee.Application.Services;

public class SkillService : ISkillService
{
    private readonly ISkillRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;

    public SkillService(ISkillRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }

    public async Task<IEnumerable<SkillResponse>> GetAllAsync(string? category = null, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Skill", "All");
        
        var items = await _cacheService.GetOrSetAsync(cacheKey, async (ct) => 
        {
            var skills = await _repository.GetAllAsync(ct);
            return skills.Select(s => new SkillResponse
            {
                Id = s.Id,
                SkillName = s.SkillName,
                SkillCategory = s.SkillCategory,
                Description = s.Description,
                IsActive = s.IsActive,
                CreatedAt = s.CreatedAt
            }).ToList();
        }, CacheOptions.Default, cancellationToken);

        if (!string.IsNullOrEmpty(category) && items != null)
        {
            return items.Where(s => s.SkillCategory == category);
        }

        return items ?? new List<SkillResponse>();
    }

    public async Task<SkillResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Skill", id.ToString());

        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) => 
        {
            var skill = await _repository.GetByIdAsync(id, ct);
            if (skill == null) return null;

            return new SkillResponse
            {
                Id = skill.Id,
                SkillName = skill.SkillName,
                SkillCategory = skill.SkillCategory,
                Description = skill.Description,
                IsActive = skill.IsActive,
                CreatedAt = skill.CreatedAt
            };
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<SkillResponse> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken = default)
    {
        var skill = new Skill
        {
            SkillName = request.SkillName,
            SkillCategory = request.SkillCategory,
            Description = request.Description,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(skill, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return new SkillResponse
        {
            Id = created.Id,
            SkillName = created.SkillName,
            SkillCategory = created.SkillCategory,
            Description = created.Description,
            IsActive = created.IsActive,
            CreatedAt = created.CreatedAt
        };
    }

    public async Task<SkillResponse> UpdateAsync(short id, UpdateSkillRequest request, CancellationToken cancellationToken = default)
    {
        var skill = await _repository.GetByIdAsync(id, cancellationToken);
        if (skill == null) throw new KeyNotFoundException($"Skill with ID {id} not found.");

        skill.SkillName = request.SkillName;
        skill.SkillCategory = request.SkillCategory;
        skill.Description = request.Description;

        _repository.Update(skill);
        await _repository.SaveChangesAsync(cancellationToken);

        return new SkillResponse
        {
            Id = skill.Id,
            SkillName = skill.SkillName,
            SkillCategory = skill.SkillCategory,
            Description = skill.Description,
            IsActive = skill.IsActive,
            CreatedAt = skill.CreatedAt
        };
    }

    public async Task<bool> ToggleStatusAsync(short id, bool isActive, CancellationToken cancellationToken = default)
    {
        var skill = await _repository.GetByIdAsync(id, cancellationToken);
        if (skill == null) return false;

        skill.IsActive = isActive;
        _repository.Update(skill);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
