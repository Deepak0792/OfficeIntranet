using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowAssignmentRepository(WorkflowDbContext dbContext) :
    BaseRepository<WorkflowAssignment, Guid, WorkflowDbContext>(dbContext),
    IWorkflowAssignmentRepository
{
    public async Task<IEnumerable<WorkflowAssignment>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Definition)
            .Where(x => x.WorkflowDefinitionId == definitionId)
            .ToListAsync(cancellationToken);

    public async Task<WorkflowDefinition?> ResolveDefinitionAsync(
        string moduleCode, Guid employeeId, DateOnly effectiveDate, CancellationToken cancellationToken = default)
    {
        // Get employee's org data via raw SQL join across schemas
        // Walks: EMPLOYEE(7) → TEAM(6) → DEPARTMENT(5) → OFFICE(4) → LEGAL_ENTITY(3) → COUNTRY(2) → GLOBAL(1)
        // Returns highest priority (lowest PriorityOrder number) active assignment.
        var query = @"
            SELECT TOP 1 wd.Id, wd.WorkflowCode, wd.WorkflowName, wd.VersionNo, wd.WorkflowModuleId
            FROM workflow.WorkflowAssignment wa
            JOIN workflow.WorkflowDefinition wd
                ON wd.Id = wa.WorkflowDefinitionId AND wd.IsActive = 1
            JOIN workflow.WorkflowModule wm
                ON wm.Id = wd.WorkflowModuleId AND wm.ModuleCode = {0} AND wm.IsActive = 1
            JOIN time.ScopeType st
                ON st.Id = wa.ScopeTypeId
            WHERE wa.IsActive = 1
              AND wa.EffectiveFrom <= {1}
              AND (wa.EffectiveTo IS NULL OR wa.EffectiveTo >= {1})
              AND (
                    -- GLOBAL scope (ScopeReferenceId = 1)
                    (st.ScopeCode = 'GLOBAL')
                    -- EMPLOYEE direct match
                 OR (st.ScopeCode = 'EMPLOYEE' AND wa.ScopeReferenceId = {2})
                    -- DEPARTMENT match
                 OR (st.ScopeCode = 'DEPARTMENT' AND wa.ScopeReferenceId IN (
                        SELECT DepartmentId FROM employee.EmployeeDepartment
                        WHERE EmployeeId = {2} AND IsPrimaryDepartment = 1 AND IsActive = 1))
                    -- OFFICE match
                 OR (st.ScopeCode = 'OFFICE' AND wa.ScopeReferenceId IN (
                        SELECT LocationId FROM employee.EmployeeLocation
                        WHERE EmployeeId = {2} AND IsPrimaryLocation = 1 AND IsActive = 1))
                    -- LEGAL_ENTITY match
                 OR (st.ScopeCode = 'LEGAL_ENTITY' AND wa.ScopeReferenceId IN (
                        SELECT LegalEntityId FROM employee.EmployeeLegalEntity
                        WHERE EmployeeId = {2} AND IsPrimary = 1 AND IsActive = 1))
                    -- TEAM match
                 OR (st.ScopeCode = 'TEAM' AND wa.ScopeReferenceId IN (
                        SELECT TeamId FROM employee.EmployeeTeam
                        WHERE EmployeeId = {2} AND IsActive = 1))
              )
            ORDER BY st.HierarchyLevel DESC, wa.PriorityOrder ASC";

        var results = await _dbContext.WorkflowDefinitions
            .FromSqlRaw(query, moduleCode, effectiveDate.ToDateTime(TimeOnly.MinValue), employeeId)
            .Include(d => d.Module)
            .ToListAsync(cancellationToken);

        return results.FirstOrDefault();
    }

    public async Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsActive = !entity.IsActive;
        Update(entity);
        return true;
    }
}
