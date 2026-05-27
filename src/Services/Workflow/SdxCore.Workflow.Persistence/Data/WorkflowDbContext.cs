using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Outbox;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Persistence.Data;

public class WorkflowDbContext : DbContext
{
    public WorkflowDbContext(DbContextOptions<WorkflowDbContext> options) : base(options) { }

    public DbSet<WorkflowModule> WorkflowModules => Set<WorkflowModule>();
    public DbSet<WorkflowDefinition> WorkflowDefinitions => Set<WorkflowDefinition>();
    public DbSet<WorkflowStep> WorkflowSteps => Set<WorkflowStep>();
    public DbSet<WorkflowStepApprover> WorkflowStepApprovers => Set<WorkflowStepApprover>();
    public DbSet<WorkflowStepApproverDesignation> WorkflowStepApproverDesignations => Set<WorkflowStepApproverDesignation>();
    public DbSet<WorkflowAssignment> WorkflowAssignments => Set<WorkflowAssignment>();
    public DbSet<WorkflowInstance> WorkflowInstances => Set<WorkflowInstance>();
    public DbSet<WorkflowTask> WorkflowTasks => Set<WorkflowTask>();
    public DbSet<WorkflowActionHistory> WorkflowActionHistories => Set<WorkflowActionHistory>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("workflow");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(WorkflowDbContext).Assembly);
    }
}
