using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowStepApproverDesignationService(
    IWorkflowStepApproverDesignationRepository repo,
    IWorkflowStepApproverRepository approverRepo,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    IWorkflowUnitOfWork _unitOfWork) : IWorkflowStepApproverDesignationService
{
    public async Task<IEnumerable<WorkflowStepApproverDesignationResponse>> GetByApproverIdAsync(Guid approverId, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStepApproverDesignation), $"approver_{approverId}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var items = await repo.GetByApproverIdAsync(approverId, ct);
            return PropertyMapper.MapList<WorkflowStepApproverDesignation, WorkflowStepApproverDesignationResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? Enumerable.Empty<WorkflowStepApproverDesignationResponse>();
    }

    public async Task<WorkflowStepApproverDesignationResponse> AddAsync(Guid approverId, AddApproverDesignationRequest request, CancellationToken cancellationToken = default)
    {
        _ = await approverRepo.GetByIdAsync(approverId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStepApprover", approverId);

        if (await repo.ExistsAsync(approverId, request.DesignationId, cancellationToken))
            throw new InvalidOperationException(
                $"Designation {request.DesignationId} is already mapped to approver {approverId}.");

        var entity = new WorkflowStepApproverDesignation
        {
            WorkflowStepApproverId = approverId,
            DesignationId = request.DesignationId,
            IsActive = true
        };
        await repo.AddAsync(entity, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowStepApproverDesignationResponse>(entity);
    }

    public async Task<bool> DeleteAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default)
    {
        var deleted = await repo.DeleteAsync(approverId, designationId, cancellationToken);
        if (deleted)
        {
            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }
        return deleted;
    }
}
