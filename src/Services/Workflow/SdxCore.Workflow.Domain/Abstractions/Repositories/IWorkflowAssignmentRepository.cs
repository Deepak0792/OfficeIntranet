using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowAssignmentRepository : IRepository<WorkflowAssignment, Guid>
{
    Task<IEnumerable<WorkflowAssignment>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Resolves which WorkflowDefinition applies for a given module + employee.
    /// Walks the scope hierarchy (Employee → Team → Dept → Office → LegalEntity → Country → Global)
    /// and returns the highest-priority active assignment effective on the given date.
    /// </summary>
    Task<WorkflowDefinition?> ResolveDefinitionAsync(
        string moduleCode,
        Guid employeeId,
        DateOnly effectiveDate,
        CancellationToken cancellationToken = default);
}
