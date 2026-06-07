using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowStepService(
    IWorkflowStepRepository _repository,
    IWorkflowDefinitionRepository defRepo,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : IWorkflowStepService
{
    public async Task<IEnumerable<WorkflowStepResponse>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStep), $"definition_{definitionId}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var steps = await _repository.GetByDefinitionIdAsync(definitionId, ct);
            return PropertyMapper.MapList<WorkflowStep, WorkflowStepResponse>(steps.OrderBy(s => s.StepNo));
        }, CacheOptions.StaticMasterData, cancellationToken) ?? Enumerable.Empty<WorkflowStepResponse>();
    }

    public async Task<WorkflowStepResponse> GetByIdAsync(short definitionId, short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStep), $"definition_{definitionId}_step{id}_with_approvers");
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var step = await _repository.GetWithApproversAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowStep", id);
            return PropertyMapper.MapToRecord<WorkflowStepResponse>(step);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowStepResponse> GetByIdAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowStep), $"step{id}_with_approvers");
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var step = await _repository.GetWithApproversAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowStep", id);
            return PropertyMapper.MapToRecord<WorkflowStepResponse>(step);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowStepResponse?> GetNextStepAsync(short definitionId, short currentStepNo, CancellationToken cancellationToken = default)
    {
        var steps = await GetByDefinitionIdAsync(definitionId, cancellationToken);
        return steps.Where(x => x.StepNo > currentStepNo && x.IsActive).OrderBy(s => s.StepNo).FirstOrDefault();
    }

    public async Task<WorkflowStepResponse> CreateAsync(short definitionId, CreateWorkflowStepRequest request, CancellationToken cancellationToken = default)
    {
        _ = await defRepo.GetByIdAsync(definitionId, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowDefinition", definitionId);

        var entity = new WorkflowStep
        {
            WorkflowDefinitionId = definitionId,
            StepNo = request.StepNo,
            StepName = request.StepName,
            WorkflowStepType = request.WorkflowStepType,
            IsFinalStep = request.IsFinalStep,
            AllowDelegation = request.AllowDelegation,
            EscalationAfterHours = request.EscalationAfterHours,
            IsActive = true
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowStepResponse>(entity);
    }

    public async Task<WorkflowStepResponse> UpdateAsync(short definitionId, short id, UpdateWorkflowStepRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowStep", id);

        entity.StepName = request.StepName;
        entity.WorkflowStepType = request.WorkflowStepType;
        entity.IsFinalStep = request.IsFinalStep;
        entity.AllowDelegation = request.AllowDelegation;
        entity.EscalationAfterHours = request.EscalationAfterHours;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowStepResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(short definitionId, short id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> ReorderAsync(short definitionId, short id, ReorderWorkflowStepRequest request, CancellationToken cancellationToken = default)
    {
        await _repository.ReorderAsync(definitionId, id, request.StepNo, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}
