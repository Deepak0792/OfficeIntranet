using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeTeamService : IEmployeeTeamService
{
    private readonly IEmployeeTeamRepository _repository;
    private readonly ITeamRepository _teamRepository;

    public EmployeeTeamService(IEmployeeTeamRepository repository, ITeamRepository teamRepository)
    {
        _repository = repository;
        _teamRepository = teamRepository;
    }

    public async Task<IEnumerable<EmployeeTeamResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var teams = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        var responses = new List<EmployeeTeamResponse>();
        foreach (var team in teams)
        {
            var teamMaster = await _teamRepository.GetByIdAsync(team.TeamId, cancellationToken);

            var employeeTeam = PropertyMapper.Map<EmployeeTeam, EmployeeTeamResponse>(team);
            employeeTeam.TeamName = teamMaster?.TeamName;

            responses.Add(employeeTeam);
        }
        return responses;
    }

    public async Task<EmployeeTeamResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (team == null) return null;

        var teamMaster = await _teamRepository.GetByIdAsync(team.TeamId, cancellationToken);

        var employeeTeam = PropertyMapper.Map<EmployeeTeam, EmployeeTeamResponse>(team);
        employeeTeam.TeamName = teamMaster?.TeamName;

        return employeeTeam;
    }

    public async Task<EmployeeTeamResponse> AddAsync(int employeeId, CreateEmployeeTeamRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeTeamRequest, EmployeeTeam>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created team");
    }

    public async Task<EmployeeTeamResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeTeamRequest request, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (team == null) throw new KeyNotFoundException("Employee team not found");

        team.RoleInTeam = request.RoleInTeam;
        team.AllocationPercentage = request.AllocationPercentage;
        team.StartDate = request.StartDate;
        team.EndDate = request.EndDate;

        _repository.Update(team);
        await _repository.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, team.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated team");
    }

    public async Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (team == null) return false;

        team.IsActive = isActive;
        _repository.Update(team);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
