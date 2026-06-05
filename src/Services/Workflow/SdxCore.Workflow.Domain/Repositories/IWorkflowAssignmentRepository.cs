using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowAssignmentRepository : IRepository<WorkflowAssignment, short>
{
    Task<IEnumerable<WorkflowAssignment>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Resolves which WorkflowDefinition applies for a given module + employee.
    /// Walks the scope hierarchy (Employee → Team → Dept → Office → LegalEntity → Country → Global)
    /// and returns the highest-priority active assignment effective on the given date.
    /// </summary>
    Task<WorkflowDefinition?> ResolveDefinitionAsync(
        string moduleCode,
        int employeeId,
        DateOnly effectiveDate,
        CancellationToken cancellationToken = default);
}
