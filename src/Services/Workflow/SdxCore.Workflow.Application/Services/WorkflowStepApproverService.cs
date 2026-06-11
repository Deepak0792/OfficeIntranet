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

public class WorkflowStepApproverService(
    IWorkflowStepApproverRepository approverRepository,
    IWorkflowStepRepository stepRepo,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    IWorkflowUnitOfWork _unitOfWork) : IWorkflowStepApproverService
{
    public async Task<IEnumerable<WorkflowStepApproverResponse>> GetByStepIdAsync(Guid stepId, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStepApprover), $"step_{stepId}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var items = await approverRepository.GetByStepIdAsync(stepId, ct);
            return PropertyMapper.MapList<WorkflowStepApprover, WorkflowStepApproverResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? Enumerable.Empty<WorkflowStepApproverResponse>();
    }

    public async Task<WorkflowStepApproverResponse> GetByIdAsync(Guid stepId, Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStepApprover), id.ToString());
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var e = await approverRepository.GetWithDesignationsAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowStepApprover", id);
            return PropertyMapper.MapToRecord<WorkflowStepApproverResponse>(e);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<IEnumerable<Guid>> GetDesignationIdsAsync(Guid approverId, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStepApprover), $"designation{approverId}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            return await approverRepository.GetDesignationIdsAsync(approverId, ct);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<WorkflowStepApproverResponse> CreateAsync(Guid stepId, CreateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default)
    {
        _ = await stepRepo.GetByIdAsync(stepId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStep", stepId);

        var entity = new WorkflowStepApprover
        {
            WorkflowStepId = stepId,
            WorkflowApproverType = request.WorkflowApproverType,
            ScopeTypeId = request.ScopeTypeId,
            ScopeReferenceId = request.ScopeReferenceId,
            PriorityOrder = request.PriorityOrder,
            IsMandatory = request.IsMandatory,
            IsActive = true
        };
        await approverRepository.AddAsync(entity, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowStepApproverResponse>(entity);
    }

    public async Task<WorkflowStepApproverResponse> UpdateAsync(Guid stepId, Guid id, UpdateWorkflowStepApproverRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await approverRepository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStepApprover", id);

        entity.ScopeTypeId = request.ScopeTypeId;
        entity.ScopeReferenceId = request.ScopeReferenceId;
        entity.PriorityOrder = request.PriorityOrder;
        entity.IsMandatory = request.IsMandatory;

        approverRepository.Update(entity);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowStepApproverResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid stepId, Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await approverRepository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        approverRepository.Update(entity);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}