using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Assignment.Request;
using SdxCore.Workflow.Application.DTOs.Assignment.Response;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Shared.Request;
using SdxCore.Workflow.Domain.Abstractions;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowAssignmentService(IWorkflowAssignmentRepository repository, IWorkflowUnitOfWork unitOfWork) : IWorkflowAssignmentService
{
    public async Task<IEnumerable<WorkflowAssignmentResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var items = await repository.GetAllAsync(cancellationToken);
        return PropertyMapper.MapList<WorkflowAssignment, WorkflowAssignmentResponse>(items);
    }

    public async Task<WorkflowAssignmentResponse> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var e = await repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowAssignment", id);
        return PropertyMapper.Map<WorkflowAssignment, WorkflowAssignmentResponse>(e);
    }

    public async Task<IEnumerable<WorkflowAssignmentResponse>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default)
    {
        var items = await repository.GetByDefinitionIdAsync(definitionId, cancellationToken);
        return PropertyMapper.MapList<WorkflowAssignment, WorkflowAssignmentResponse>(items);
    }

    public async Task<ResolveDefinitionResponse> ResolveAsync(string moduleCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default)
    {
        var date = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var def = await repository.ResolveDefinitionAsync(moduleCode, employeeId, date, cancellationToken)
            ?? throw new WorkflowDefinitionNotFoundException(moduleCode);
        return PropertyMapper.Map<WorkflowDefinition, ResolveDefinitionResponse>(def);
    }

    public async Task<WorkflowAssignmentResponse> CreateAsync(CreateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateWorkflowAssignmentRequest, WorkflowAssignment>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<WorkflowAssignment, WorkflowAssignmentResponse>(entity);
    }

    public async Task<WorkflowAssignmentResponse> UpdateAsync(Guid id, UpdateWorkflowAssignmentRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken)
            ?? throw new WorkflowNotFoundException("WorkflowAssignment", id);

        PropertyMapper.Patch<UpdateWorkflowAssignmentRequest, WorkflowAssignment>(request, entity);

        repository.Update(entity);

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return PropertyMapper.Map<WorkflowAssignment, WorkflowAssignmentResponse>(entity);
    }

    public async Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;

        entity.IsActive = request.IsActive;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }
}
