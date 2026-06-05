using Microsoft.AspNetCore.Mvc;
using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;
public class WorkflowDefinitionService(
    IWorkflowDefinitionRepository _repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : IWorkflowDefinitionService
{
    public async Task<PagedResponse<IEnumerable<WorkflowDefinitionResponse>>> GetPagedAsync(PaginationFilter filter, CancellationToken cancellationToken = default)
    {
        var (items, total) = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var res = PropertyMapper.MapList<WorkflowDefinition, WorkflowDefinitionResponse>(items);
        return new PagedResponse<IEnumerable<WorkflowDefinitionResponse>>(res, filter.PageNumber, filter.PageSize, total);
    }

    public async Task<WorkflowDefinitionResponse> GetByIdAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowDefinition), id.ToString());
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var e = await _repository.GetByIdAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowDefinition", id);
            return PropertyMapper.MapToRecord<WorkflowDefinitionResponse>(e);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowDefinitionResponse> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowDefinition), $"code_{workflowCode}");
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var e = await _repository.GetByCodeAsync(workflowCode, ct)
                ?? throw new WorkflowNotFoundException("WorkflowDefinition", workflowCode);
            return PropertyMapper.MapToRecord<WorkflowDefinitionResponse>(e);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<IEnumerable<WorkflowDefinitionResponse>> GetByModuleIdAsync(short moduleId, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowDefinition), $"module_{moduleId}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var items = await _repository.GetByModuleIdAsync(moduleId, ct);
            return PropertyMapper.MapList<WorkflowDefinition, WorkflowDefinitionResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? Enumerable.Empty<WorkflowDefinitionResponse>();
    }

    public async Task<WorkflowDefinitionWithStepsResponse> GetWithStepsAsync(short id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowDefinition), $"withsteps_{id}");
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var e = await _repository.GetWithStepsAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowDefinition", id);

            return new WorkflowDefinitionWithStepsResponse(
                e.Id, e.WorkflowCode, e.WorkflowName, e.VersionNo, e.IsActive,
                e.Steps.OrderBy(s => s.StepNo).Select(s => PropertyMapper.MapToRecord<WorkflowStepResponse>(s)));
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowDefinitionResponse> CreateAsync(CreateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default)
    {
        if (await _repository.GetByCodeAsync(request.WorkflowCode, cancellationToken) is not null)
            throw new DuplicateWorkflowCodeException(request.WorkflowCode);

        var entity = new WorkflowDefinition
        {
            WorkflowModuleId = request.WorkflowModuleId,
            WorkflowCode = request.WorkflowCode.ToUpperInvariant(),
            WorkflowName = request.WorkflowName,
            VersionNo = request.VersionNo,
            Description = request.Description,
            IsActive = true
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowDefinitionResponse>(entity);
    }

    public async Task<WorkflowDefinitionResponse> UpdateAsync(short id, UpdateWorkflowDefinitionRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowDefinition", id);

        entity.WorkflowName = request.WorkflowName;
        entity.VersionNo = request.VersionNo;
        entity.Description = request.Description;

        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowDefinitionResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}