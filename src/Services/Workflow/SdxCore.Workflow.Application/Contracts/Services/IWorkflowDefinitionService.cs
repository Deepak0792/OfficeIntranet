using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IWorkflowDefinitionService
{
    Task<PagedResponse<IEnumerable<WorkflowDefinitionResponse>>> GetPagedAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowDefinitionResponse>> GetByModuleIdAsync(short moduleId, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionWithStepsResponse> GetWithStepsAsync(short id, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> CreateAsync(CreateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> UpdateAsync(short id, UpdateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
