using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowAssignmentService(
    IWorkflowAssignmentRepository _repository, 
    IWorkflowUnitOfWork _unitOfWork) 
    : IWorkflowAssignmentService
{
    public async Task<IEnumerable<WorkflowAssignmentResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var items = await _repository.GetAllAsync(cancellationToken);
        return PropertyMapper.MapList<WorkflowAssignment, WorkflowAssignmentResponse>(items);
    }

    public async Task<WorkflowAssignmentResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var e = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowAssignment", id);
        return PropertyMapper.MapToRecord<WorkflowAssignmentResponse>(e);
    }

    public async Task<IEnumerable<WorkflowAssignmentResponse>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default)
    {
        var items = await _repository.GetByDefinitionIdAsync(definitionId, cancellationToken);
        return PropertyMapper.MapList<WorkflowAssignment, WorkflowAssignmentResponse>(items);
    }

    public async Task<ResolveDefinitionResponse> ResolveAsync(string moduleCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default)
    {
        var date = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var def = await _repository.ResolveDefinitionAsync(moduleCode, employeeId, date, cancellationToken)
            ?? throw new WorkflowDefinitionNotFoundException(moduleCode);
        return new ResolveDefinitionResponse(def.Id, def.WorkflowCode, def.WorkflowName, def.VersionNo);
    }

    public async Task<WorkflowAssignmentResponse> CreateAsync(CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = new WorkflowAssignment
        {
            WorkflowDefinitionId = request.WorkflowDefinitionId,
            ScopeTypeId = request.ScopeTypeId,
            ScopeReferenceId = request.ScopeReferenceId,
            EffectiveFrom = request.EffectiveFrom,
            EffectiveTo = request.EffectiveTo,
            PriorityOrder = request.PriorityOrder,
            IsActive = true
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.MapToRecord<WorkflowAssignmentResponse>(entity);
    }

    public async Task<WorkflowAssignmentResponse> UpdateAsync(Guid id, UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowAssignment", id);

        entity.EffectiveFrom = request.EffectiveFrom;
        entity.EffectiveTo = request.EffectiveTo;
        entity.PriorityOrder = request.PriorityOrder;

        _repository.Update(entity);

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.MapToRecord<WorkflowAssignmentResponse>(entity);
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
}
