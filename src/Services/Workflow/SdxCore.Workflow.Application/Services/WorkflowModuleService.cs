using SdxCore.Caching;
using SdxCore.Common.Helpers;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowModuleService(
    IWorkflowModuleRepository _repository,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder,
    IWorkflowUnitOfWork _unitOfWork) : IWorkflowModuleService
{
    public async Task<IEnumerable<WorkflowModuleResponse>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowModule), $"all_active_{activeOnly}");
        return await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var items = await _repository.GetAllAsync(activeOnly, ct);
            return PropertyMapper.MapList<WorkflowModule, WorkflowModuleResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? Enumerable.Empty<WorkflowModuleResponse>();
    }

    public async Task<WorkflowModuleResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowModule), id.ToString());
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByIdAsync(id, ct)
                ?? throw new WorkflowNotFoundException("WorkflowModule", id);
            return PropertyMapper.MapToRecord<WorkflowModuleResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowModuleResponse> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default)
    {
        var cacheKey = cacheKeyBuilder.BuildKey(nameof(WorkflowModule), $"code_{moduleCode}");
        var res = await cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {
            var entity = await _repository.GetByCodeAsync(moduleCode, ct)
                ?? throw new WorkflowNotFoundException("WorkflowModule", moduleCode);
            return PropertyMapper.MapToRecord<WorkflowModuleResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
        return res!;
    }

    public async Task<WorkflowModuleResponse> CreateAsync(CreateWorkflowModuleRequest request, CancellationToken cancellationToken = default)
    {
        if (await _repository.ExistsAsync(request.ModuleCode, cancellationToken))
            throw new DuplicateWorkflowModuleCodeException(request.ModuleCode);

        var entity = PropertyMapper.Map<CreateWorkflowModuleRequest, WorkflowModule>(request);

        entity.ModuleCode = request.ModuleCode.ToUpperInvariant();
        entity.IsActive = true;

        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowModuleResponse>(entity);
    }

    public async Task<WorkflowModuleResponse> UpdateAsync(Guid id, UpdateWorkflowModuleRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowModule", id);

        entity.ModuleName = request.ModuleName;
        entity.EntityName = request.EntityName;

        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowModuleResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        _repository.Update(entity);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IEnumerable<WorkflowAssignmentSummary>> GetWorkflowAssignmentsAsync(string moduleCode, CancellationToken cancellationToken = default)
    {
        return await _repository.GetWorkflowAssignmentsAsync(moduleCode, cancellationToken);
    }
}