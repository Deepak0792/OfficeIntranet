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
            var teams = await _repository.GetAllAsync(ct);
            return teams.Select(t => new TeamResponse
            {
                Id = t.Id,
                TeamCode = t.TeamCode,
                TeamName = t.TeamName,
                TeamType = t.TeamType,
                Description = t.Description,
                IsActive = t.IsActive,
                CreatedAt = t.CreatedAt
            }).ToList();
        }, CacheOptions.Default, cancellationToken) ?? new List<TeamResponse>();
    }

    public async Task<TeamResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = _cacheKeyBuilder.BuildKey("Team", id.ToString());

        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) => 
        {
            var team = await _repository.GetByIdAsync(id, ct);
            if (team == null) return null;

            return new TeamResponse
            {
                Id = team.Id,
                TeamCode = team.TeamCode,
                TeamName = team.TeamName,
                TeamType = team.TeamType,
                Description = team.Description,
                IsActive = team.IsActive,
                CreatedAt = team.CreatedAt
            };
        }, CacheOptions.Default, cancellationToken);
    }

    public async Task<TeamResponse> CreateAsync(CreateTeamRequest request, CancellationToken cancellationToken = default)
    {
        var team = new Team
        {
            TeamCode = request.TeamCode,
            TeamName = request.TeamName,
            TeamType = request.TeamType,
            Description = request.Description,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(team, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return new TeamResponse
        {
            Id = created.Id,
            TeamCode = created.TeamCode,
            TeamName = created.TeamName,
            TeamType = created.TeamType,
            Description = created.Description,
            IsActive = created.IsActive,
            CreatedAt = created.CreatedAt
        };
    }

    public async Task<TeamResponse> UpdateAsync(short id, UpdateTeamRequest request, CancellationToken cancellationToken = default)
    {
        var team = await _repository.GetByIdAsync(id, cancellationToken);
        if (team == null) throw new KeyNotFoundException($"Team with ID {id} not found.");

        team.TeamName = request.TeamName;
        team.TeamType = request.TeamType;
        team.Description = request.Description;

        _repository.Update(team);
        await _repository.SaveChangesAsync(cancellationToken);

        return new TeamResponse
        {
            Id = team.Id,
            TeamCode = team.TeamCode,
            TeamName = team.TeamName,
            TeamType = team.TeamType,
            Description = team.Description,
            IsActive = team.IsActive,
            CreatedAt = team.CreatedAt
        };
    }

    public async Task<bool> ToggleStatusAsync(short id, bool isActive, CancellationToken cancellationToken = default)
    {
        var team = await _repository.GetByIdAsync(id, cancellationToken);
        if (team == null) return false;

        team.IsActive = isActive;
        _repository.Update(team);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
