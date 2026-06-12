using SdxCore.Common.Models;
using SdxCore.Workflow.Application.DTOs.Definition.Request;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Shared.Request;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IWorkflowDefinitionService
{
    Task<PagedResponse<IEnumerable<WorkflowDefinitionResponse>>> GetPagedAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowDefinitionResponse>> GetByModuleIdAsync(Guid moduleId, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionWithStepsResponse> GetWithStepsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> CreateAsync(CreateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default);
    Task<WorkflowDefinitionResponse> UpdateAsync(Guid id, UpdateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}
