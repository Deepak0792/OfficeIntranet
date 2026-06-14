using SdxCore.Common.Helpers;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.DTOs.EmployeeSkill.Request;
using SdxCore.Employee.Application.DTOs.EmployeeSkill.Response;
using SdxCore.Employee.Domain.Abstractions;
using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Application.Services;

public class EmployeeSkillService(
    IEmployeeSkillRepository repository,
    ISkillRepository skillRepository,
    IEmployeeUnitOfWork unitOfWork) : IEmployeeSkillService
{
    private readonly IEmployeeSkillRepository _repository = repository;
    private readonly ISkillRepository _skillRepository = skillRepository;
    private readonly IEmployeeUnitOfWork _unitOfWork = unitOfWork;

    public async Task<IEnumerable<EmployeeSkillResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default)
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

    public async Task<EmployeeSkillResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault();
        if (skill is null) return null;

        var skillMaster = await _skillRepository.GetByIdAsync(skill.SkillId, cancellationToken);
        var employeeSkill = PropertyMapper.Map<EmployeeSkill, EmployeeSkillResponse>(skill);
        employeeSkill.SkillName = skillMaster?.SkillName;

        return employeeSkill;
    }

    public async Task<EmployeeSkillResponse> AddAsync(Guid employeeId, CreateEmployeeSkillRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateEmployeeSkillRequest, EmployeeSkill>(request);
        entity.EmployeeId = employeeId;
        entity.IsActive = true;

        var created = await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, created.Id, cancellationToken) ?? throw new InvalidOperationException("Failed to retrieve created skill");
    }

    public async Task<EmployeeSkillResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeSkillRequest request, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee skill not found");
        PropertyMapper.Patch(request, skill);
        _repository.Update(skill);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(employeeId, skill.Id, cancellationToken) ?? throw new InvalidOperationException("Failed to retrieve updated skill");
    }

    public async Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default)
    {
        var skill = (await _repository.FindAsync(x => x.Id == id && x.EmployeeId == employeeId, cancellationToken)).FirstOrDefault()
            ?? throw new KeyNotFoundException("Employee skill not found");
        skill.IsActive = isActive;
        _repository.Update(skill);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default)
    {
        var skills = await _repository.FindAsync(x => x.EmployeeId == employeeId && x.IsActive, cancellationToken);
        var target = skills.FirstOrDefault(x => x.Id == id) ?? throw new KeyNotFoundException("Employee skill not found");

        foreach (var skill in skills.Where(s => s.IsPrimarySkill))
        {
            skill.IsPrimarySkill = false;
            _repository.Update(skill);
        }

        target.IsPrimarySkill = true;
        _repository.Update(target);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
