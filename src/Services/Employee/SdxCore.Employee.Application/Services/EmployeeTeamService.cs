using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeTeamService(
    IEmployeeTeamRepository repository,
    ITeamRepository teamRepository,
    IEmployeeUnitOfWork unitOfWork) : IEmployeeTeamService
{
    private readonly IEmployeeTeamRepository _repository = repository;
    private readonly ITeamRepository _teamRepository = teamRepository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeTeamResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
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

    public async Task<EmployeeTeamResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (team is null) return null;

        var teamMaster = await _teamRepository.GetByIdAsync(team.TeamId, cancellationToken);

        var employeeTeam = PropertyMapper.Map<EmployeeTeam, EmployeeTeamResponse>(team);
        employeeTeam.TeamName = teamMaster?.TeamName;

        return employeeTeam;
    }

    public async Task<EmployeeTeamResponse> AddAsync(Guid employeeId, CreateEmployeeTeamRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeTeamRequest, EmployeeTeam>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new InvalidOperationException("Failed to retrieve created team");
    }

    public async Task<EmployeeTeamResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeTeamRequest request, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee team not found");
        PropertyMapper.Patch(request, team);
        _repository.Update(team);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, team.Id, cancellationToken) ?? throw new InvalidOperationException("Failed to retrieve updated team");
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var team = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee team not found");

        team.IsActive = isActive;
        _repository.Update(team);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var team = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = team.FirstOrDefault(x => x.Id == id) ?? throw new KeyNotFoundException("Employee team not found");

        foreach (var skill in team.Where(s => s.IsPrimaryTeam))
        {
            skill.IsPrimaryTeam = false;
            _repository.Update(skill);
        }

        target.IsPrimaryTeam = true;
        _repository.Update(target);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
