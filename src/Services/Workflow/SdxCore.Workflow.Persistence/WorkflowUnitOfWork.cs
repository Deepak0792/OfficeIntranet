using SdxCore.SharedKernel.Persistence;
using SdxCore.Workflow.Domain.Abstractions;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence;


public sealed class WorkflowUnitOfWork : UnitOfWork<WorkflowDbContext>, IWorkflowUnitOfWork
{
    public WorkflowUnitOfWork(WorkflowDbContext dbContext) : base(dbContext) { }
}