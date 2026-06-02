using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface ISkillService
{
    Task<IEnumerable<SkillResponse>> GetAllAsync(string? category = null, CancellationToken cancellationToken = default);
    Task<SkillResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<SkillResponse> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken = default);
    Task<SkillResponse> UpdateAsync(short id, UpdateSkillRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, bool isActive, CancellationToken cancellationToken = default);
}
