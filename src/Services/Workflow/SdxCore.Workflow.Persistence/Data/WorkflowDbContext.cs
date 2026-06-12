using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Data;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Persistence.Data;

public class WorkflowDbContext : SdxDbContext
{
    public WorkflowDbContext(DbContextOptions<WorkflowDbContext> options)
        : base(options)
    {
    }

    // ── DbSets ────────────────────────────────────────────────────────────────
    public DbSet<WorkflowModule> WorkflowModules { get; set; }
    public DbSet<WorkflowDefinition> WorkflowDefinitions { get; set; }
    public DbSet<WorkflowStep> WorkflowSteps { get; set; }
    public DbSet<WorkflowStepApprover> WorkflowStepApprovers { get; set; }
    public DbSet<WorkflowStepApproverDesignation> WorkflowStepApproverDesignations { get; set; }
    public DbSet<WorkflowAssignment> WorkflowAssignments { get; set; }
    public DbSet<WorkflowInstance> WorkflowInstances { get; set; }
    public DbSet<WorkflowTask> WorkflowTasks { get; set; }
    public DbSet<WorkflowActionHistory> WorkflowActionHistories { get; set; }
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();
    public DbSet<WorkflowAssignmentSummary> WorkflowAssignmentSummaries { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasDefaultSchema("workflow");

        // All entity configurations are in Data/Configurations/EntityConfigurations.cs
        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(WorkflowDbContext).Assembly);
    }
}
