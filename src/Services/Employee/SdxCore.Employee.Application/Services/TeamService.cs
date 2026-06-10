using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Contracts.Services;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class TeamService : ITeamService
{
    private readonly ITeamRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;

    public TeamService(ITeamRepository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder)
    {
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }

    public async Task<IEnumerable<TeamResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Team", "All");

        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(t => PropertyMapper.Map<Team, TeamResponse>(t)).ToList();
        }, CacheOptions.Default, cancellationToken) ?? new List<TeamResponse>();
    }

    public async Task<TeamResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Team", id.ToString());

        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;

            return PropertyMapper.Map<Team, TeamResponse>(entity);
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<TeamResponse> CreateAsync(CreateTeamRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateTeamRequest, Team>(request);
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Team, TeamResponse>(created);
    }

    public async Task<TeamResponse> UpdateAsync(Guid id, UpdateTeamRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) throw new KeyNotFoundException($"Team with ID {id} not found.");

        entity.TeamName = request.TeamName;
        entity.TeamType = request.TeamType;
        entity.Description = request.Description;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Team, TeamResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = isActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
