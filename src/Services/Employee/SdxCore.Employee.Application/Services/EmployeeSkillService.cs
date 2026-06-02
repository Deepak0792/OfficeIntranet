using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;
using SdxCore.Employee.Application.Interfaces.Services;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;

namespace SdxCore.Employee.Application.Services;

public class EmployeeSkillService : IEmployeeSkillService
{
    private readonly IEmployeeSkillRepository _repository;
    private readonly ISkillRepository _skillRepository;

    public EmployeeSkillService(IEmployeeSkillRepository repository, ISkillRepository skillRepository)
    {
        _repository = repository;
        _skillRepository = skillRepository;
    }

    public async Task<IEnumerable<EmployeeSkillResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default)
    {
        var skills = await _repository.FindAsync(x => x.EmployeeId == employeeId, cancellationToken);
        
        var responses = new List<EmployeeSkillResponse>();
        foreach (var skill in skills)
        {
            var skillMaster = await _skillRepository.GetByIdAsync(skill.SkillId, cancellationToken);
            var employeeSkill = PropertyMapper.Map<EmployeeSkill, EmployeeSkillResponse>(skill);
            employeeSkill.SkillName = skillMaster?.SkillName;

            responses.Add(employeeSkill);
        }
        return responses;
    }

    public async Task<EmployeeSkillResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (skill == null) return null;

        var skillMaster = await _skillRepository.GetByIdAsync(skill.SkillId, cancellationToken);
        var employeeSkill = PropertyMapper.Map<EmployeeSkill, EmployeeSkillResponse>(skill);
        employeeSkill.SkillName = skillMaster?.SkillName;

        return employeeSkill;
    }

    public async Task<EmployeeSkillResponse> AddAsync(int employeeId, CreateEmployeeSkillRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeSkillRequest , EmployeeSkill>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new Exception("Failed to retrieve created skill");
    }

    public async Task<EmployeeSkillResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeSkillRequest request, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (skill == null) throw new KeyNotFoundException("Employee skill not found");

        skill.SkillLevel = request.SkillLevel;
        skill.YearsOfExperience = request.YearsOfExperience;
        skill.LastUsedDate = request.LastUsedDate;

        _repository.Update(skill);
        await _repository.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, skill.Id, cancellationToken) ?? throw new Exception("Failed to retrieve updated skill");
    }

    public async Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (skill == null) return false;

        skill.IsActive = isActive;
        _repository.Update(skill);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default)
    {
        var skills = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = skills.FirstOrDefault(x => x.Id == id);
        if (target == null) return false;

        foreach (var skill in skills.Where(s => s.IsPrimarySkill))
        {
            skill.IsPrimarySkill = false;
            _repository.Update(skill);
        }

        target.IsPrimarySkill = true;
        _repository.Update(target);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
