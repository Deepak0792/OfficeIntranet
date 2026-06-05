using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowModuleService
{
    Task<IEnumerable<WorkflowModuleResponse>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> CreateAsync(CreateWorkflowModuleRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> UpdateAsync(short id, UpdateWorkflowModuleRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
