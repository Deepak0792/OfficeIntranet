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
    // ── DbSets ───────────────────────────────────────────────
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

        // ── WorkflowModule ───────────────────────────────────
        modelBuilder.Entity<WorkflowModule>(e =>
        {
            e.ToTable("WorkflowModule", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.ModuleCode).HasMaxLength(100).IsRequired();
            e.Property(x => x.ModuleName).HasMaxLength(200).IsRequired();
            e.Property(x => x.EntityName).HasMaxLength(100).IsRequired();
            e.HasIndex(x => x.ModuleCode).IsUnique();

            e.HasMany(x => x.Definitions)
             .WithOne(d => d.Module)
             .HasForeignKey(d => d.WorkflowModuleId);
        });

        // ── WorkflowDefinition ───────────────────────────────
        modelBuilder.Entity<WorkflowDefinition>(e =>
        {
            e.ToTable("WorkflowDefinition", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.WorkflowCode).HasMaxLength(100).IsRequired();
            e.Property(x => x.WorkflowName).HasMaxLength(200).IsRequired();
            e.Property(x => x.Description).HasMaxLength(1000);
            e.HasIndex(x => x.WorkflowCode).IsUnique();

            e.HasMany(x => x.Steps)
             .WithOne(s => s.Definition)
             .HasForeignKey(s => s.WorkflowDefinitionId);

            e.HasMany(x => x.Assignments)
             .WithOne(a => a.Definition)
             .HasForeignKey(a => a.WorkflowDefinitionId);
        });

        // ── WorkflowStep ─────────────────────────────────────
        modelBuilder.Entity<WorkflowStep>(e =>
        {
            e.ToTable("WorkflowStep", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.StepName).HasMaxLength(200).IsRequired();
            e.Property(x => x.WorkflowStepType).HasMaxLength(50).IsRequired();
            // WorkflowStepTypeGroup is a computed persisted column — never written by EF
            e.Property<string>("WorkflowStepTypeGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_STEP_TYPE' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);
            e.HasIndex(x => new { x.WorkflowDefinitionId, x.StepNo }).IsUnique();

            e.HasMany(x => x.Approvers)
             .WithOne(a => a.Step)
             .HasForeignKey(a => a.WorkflowStepId);
        });

        // ── WorkflowStepApprover ─────────────────────────────
        modelBuilder.Entity<WorkflowStepApprover>(e =>
        {
            e.ToTable("WorkflowStepApprover", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.WorkflowApproverType).HasMaxLength(50).IsRequired();
            e.Property<string>("WorkflowApproverTypeGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_APPROVER_TYPE' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);

            e.HasMany(x => x.Designations)
             .WithOne(d => d.Approver)
             .HasForeignKey(d => d.WorkflowStepApproverId);
        });

        // ── WorkflowStepApproverDesignation ──────────────────
        modelBuilder.Entity<WorkflowStepApproverDesignation>(e =>
        {
            e.ToTable("WorkflowStepApproverDesignation", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.HasIndex(x => new { x.WorkflowStepApproverId, x.DesignationId }).IsUnique();
        });

        // ── WorkflowAssignment ───────────────────────────────
        modelBuilder.Entity<WorkflowAssignment>(e =>
        {
            e.ToTable("WorkflowAssignment", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
        });

        // ── WorkflowInstance ─────────────────────────────────
        modelBuilder.Entity<WorkflowInstance>(e =>
        {
            e.ToTable("WorkflowInstance", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.WorkflowStatus).HasMaxLength(50).IsRequired();
            e.Property<string>("WorkflowStatusGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);

            e.HasOne(x => x.Definition)
             .WithMany()
             .HasForeignKey(x => x.WorkflowDefinitionId);

            e.HasOne(x => x.Module)
             .WithMany()
             .HasForeignKey(x => x.WorkflowModuleId);

            e.HasOne(x => x.CurrentStep)
             .WithMany()
             .HasForeignKey(x => x.CurrentWorkflowStepId)
             .IsRequired(false);

            e.HasMany(x => x.Tasks)
             .WithOne(t => t.Instance)
             .HasForeignKey(t => t.WorkflowInstanceId);

            e.HasMany(x => x.History)
             .WithOne(h => h.Instance)
             .HasForeignKey(h => h.WorkflowInstanceId);
        });

        // ── WorkflowTask ─────────────────────────────────────
        modelBuilder.Entity<WorkflowTask>(e =>
        {
            e.ToTable("WorkflowTask", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.TaskStatus).HasMaxLength(50).IsRequired();
            e.Property(x => x.Remarks).HasMaxLength(2000);
            e.Property<string>("TaskStatusGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_TASK_STATUS' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);

            e.HasOne(x => x.Step)
             .WithMany()
             .HasForeignKey(x => x.WorkflowStepId);

            e.HasOne(x => x.StepApprover)
             .WithMany()
             .HasForeignKey(x => x.WorkflowStepApproverId);

            e.HasOne(x => x.ParentTask)
             .WithMany()
             .HasForeignKey(x => x.ParentWorkflowTaskId)
             .IsRequired(false);
        });

        // ── WorkflowActionHistory ─────────────────────────────
        modelBuilder.Entity<WorkflowActionHistory>(e =>
        {
            e.ToTable("WorkflowActionHistory", "workflow");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityColumn();
            e.Property(x => x.WorkflowActionType).HasMaxLength(50).IsRequired();
            e.Property(x => x.Remarks).HasMaxLength(2000);
            e.Property(x => x.FromWorkflowStatus).HasMaxLength(50);
            e.Property(x => x.ToWorkflowStatus).HasMaxLength(50);
            // Two independent computed columns for FK into shared.StatusLookup
            e.Property<string>("FromWorkflowStatusGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);
            e.Property<string>("ToWorkflowStatusGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);
            e.Property<string>("WorkflowActionTypeGroup")
             .HasComputedColumnSql("CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50))", stored: true)
             .HasMaxLength(50);

            e.HasOne(x => x.Task)
             .WithMany()
             .HasForeignKey(x => x.WorkflowTaskId)
             .IsRequired(false);

            e.HasOne(x => x.Step)
             .WithMany()
             .HasForeignKey(x => x.WorkflowStepId)
             .IsRequired(false);
        });

        modelBuilder.Entity<WorkflowAssignmentSummary>(e =>
        {
            e.HasNoKey();

            e.ToView("vwWorkflowAssignment", "workflow");

            e.Property(x => x.WorkflowModuleId);
            e.Property(x => x.ModuleCode);
            e.Property(x => x.WorkflowDefinitionId);
            e.Property(x => x.WorkflowCode);
            e.Property(x => x.WorkflowName);
            e.Property(x => x.VersionNo);
            e.Property(x => x.WorkflowAssignmentId);
            e.Property(x => x.ScopeTypeId);
            e.Property(x => x.ScopeReferenceId);
            e.Property(x => x.PriorityOrder);
        });

        modelBuilder.Entity<OutboxMessage>(b =>
        {
            b.ToTable("OutboxMessages", "time");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id)
                .HasDefaultValueSql("NEWSEQUENTIALID()");
        });
    }
}
