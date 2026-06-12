using SdxCore.Workflow.Application.DTOs.Module.Request;
using SdxCore.Workflow.Application.DTOs.Module.Response;
using SdxCore.Workflow.Application.DTOs.Shared.Request;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowModuleService
{
    Task<IEnumerable<WorkflowModuleResponse>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> CreateAsync(CreateWorkflowModuleRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowModuleResponse> UpdateAsync(Guid id, UpdateWorkflowModuleRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowAssignmentSummary>> GetWorkflowAssignmentsAsync(string moduleCode, CancellationToken cancellationToken = default);
}
