using SdxCore.Employee.Application.DTOs.Skill.Request;
using SdxCore.Employee.Application.DTOs.Skill.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface ISkillService
{
    Task<IEnumerable<SkillResponse>> GetAllAsync(string? category = null, CancellationToken cancellationToken = default);
    Task<SkillResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<SkillResponse> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken = default);
    Task<SkillResponse> UpdateAsync(Guid id, UpdateSkillRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default);
}
