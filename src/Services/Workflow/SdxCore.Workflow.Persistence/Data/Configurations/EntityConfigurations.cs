using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.SharedKernel.Entities;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Persistence.Data.Configurations;

/// <summary>
/// Consolidates all IEntityTypeConfiguration&lt;T&gt; classes for the workflow schema.
/// Applied via ApplyConfigurationsFromAssembly in WorkflowDbContext.
///
/// Schema boundary rule:
///   - Navigation properties are ONLY configured for entities within the workflow schema.
///   - Cross-schema FKs (employee.Employee, time.ScopeType, time.Designation, shared.StatusLookup)
///     are stored as plain IDs — EF is NOT told about them to avoid cross-schema constraint conflicts.
/// </summary>

public sealed class WorkflowModuleConfiguration : IEntityTypeConfiguration<WorkflowModule>
{
    public void Configure(EntityTypeBuilder<WorkflowModule> builder)
    {
        builder.ToTable("WorkflowModule", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.ModuleCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.ModuleName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Schema).HasColumnName("Schema").HasMaxLength(50).IsRequired();
        builder.Property(e => e.EntityName).HasMaxLength(100).IsRequired();

        builder.HasIndex(e => e.ModuleCode).IsUnique();

        // Reverse navigation to definitions
        builder.HasMany(e => e.Definitions)
            .WithOne(d => d.Module)
            .HasForeignKey(d => d.WorkflowModuleId)
            .OnDelete(DeleteBehavior.Restrict);

        // Reverse navigation to instances
        builder.HasMany(e => e.Instances)
            .WithOne(i => i.Module)
            .HasForeignKey(i => i.WorkflowModuleId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class WorkflowDefinitionConfiguration : IEntityTypeConfiguration<WorkflowDefinition>
{
    public void Configure(EntityTypeBuilder<WorkflowDefinition> builder)
    {
        builder.ToTable("WorkflowDefinition", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.WorkflowCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.WorkflowName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);

        builder.HasIndex(e => e.WorkflowCode).IsUnique();

        // Module nav configured from WorkflowModuleConfiguration

        // Steps within this definition
        builder.HasMany(e => e.Steps)
            .WithOne(s => s.Definition)
            .HasForeignKey(s => s.WorkflowDefinitionId)
            .OnDelete(DeleteBehavior.Cascade);

        // Assignments that route to this definition
        builder.HasMany(e => e.Assignments)
            .WithOne(a => a.Definition)
            .HasForeignKey(a => a.WorkflowDefinitionId)
            .OnDelete(DeleteBehavior.Restrict);

        // Runtime instances of this definition
        builder.HasMany(e => e.Instances)
            .WithOne(i => i.Definition)
            .HasForeignKey(i => i.WorkflowDefinitionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class WorkflowStepConfiguration : IEntityTypeConfiguration<WorkflowStep>
{
    public void Configure(EntityTypeBuilder<WorkflowStep> builder)
    {
        builder.ToTable("WorkflowStep", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.StepName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.WorkflowStepType).HasMaxLength(50).IsRequired();

        // WorkflowStepTypeGroup is a computed persisted column — never written by EF
        builder.Property<string>("WorkflowStepTypeGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_STEP_TYPE' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);

        builder.HasIndex(e => new { e.WorkflowDefinitionId, e.StepNo }).IsUnique();

        // Definition nav configured from WorkflowDefinitionConfiguration

        // Approver resolution rules for this step
        builder.HasMany(e => e.Approvers)
            .WithOne(a => a.Step)
            .HasForeignKey(a => a.WorkflowStepId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class WorkflowStepApproverConfiguration : IEntityTypeConfiguration<WorkflowStepApprover>
{
    public void Configure(EntityTypeBuilder<WorkflowStepApprover> builder)
    {
        builder.ToTable("WorkflowStepApprover", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.WorkflowApproverType).HasMaxLength(50).IsRequired();

        // WorkflowApproverTypeGroup is a computed persisted column — never written by EF
        builder.Property<string>("WorkflowApproverTypeGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_APPROVER_TYPE' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);

        builder.HasIndex(e => e.WorkflowStepId);
        builder.HasIndex(e => new { e.ScopeTypeId, e.ScopeReferenceId });

        // ScopeTypeId: cross-schema FK to time.ScopeType — ID only, no EF relationship
        // Step nav configured from WorkflowStepConfiguration

        // Designation qualifiers for this rule
        builder.HasMany(e => e.Designations)
            .WithOne(d => d.Approver)
            .HasForeignKey(d => d.WorkflowStepApproverId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class WorkflowStepApproverDesignationConfiguration : IEntityTypeConfiguration<WorkflowStepApproverDesignation>
{
    public void Configure(EntityTypeBuilder<WorkflowStepApproverDesignation> builder)
    {
        builder.ToTable("WorkflowStepApproverDesignation", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // DesignationId: cross-schema FK to time.Designation — ID only, no EF relationship
        builder.HasIndex(e => new { e.WorkflowStepApproverId, e.DesignationId }).IsUnique();

        // Approver nav configured from WorkflowStepApproverConfiguration
    }
}

public sealed class WorkflowAssignmentConfiguration : IEntityTypeConfiguration<WorkflowAssignment>
{
    public void Configure(EntityTypeBuilder<WorkflowAssignment> builder)
    {
        builder.ToTable("WorkflowAssignment", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // ScopeTypeId: cross-schema FK to time.ScopeType — ID only, no EF relationship
        builder.HasIndex(e => new { e.ScopeTypeId, e.ScopeReferenceId });

        // Definition nav configured from WorkflowDefinitionConfiguration
    }
}

public sealed class WorkflowInstanceConfiguration : IEntityTypeConfiguration<WorkflowInstance>
{
    public void Configure(EntityTypeBuilder<WorkflowInstance> builder)
    {
        builder.ToTable("WorkflowInstance", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.WorkflowStatus).HasMaxLength(50).IsRequired();

        // WorkflowStatusGroup is a computed persisted column — never written by EF
        builder.Property<string>("WorkflowStatusGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);

        builder.HasIndex(e => new { e.WorkflowModuleId, e.ReferenceTransactionId });
        builder.HasIndex(e => e.CreatedBy);
        builder.HasIndex(e => e.CurrentWorkflowStepId);

        // CreatedBy, CompletedBy: cross-schema FKs to employee.Employee — ID only, no EF relationship

        // Definition + Module navs configured from their respective configurations

        // CurrentStep nav (optional — null when completed/cancelled)
        builder.HasOne(e => e.CurrentStep)
            .WithMany()
            .HasForeignKey(e => e.CurrentWorkflowStepId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // Tasks and History are configured from their respective configurations
    }
}

public sealed class WorkflowTaskConfiguration : IEntityTypeConfiguration<WorkflowTask>
{
    public void Configure(EntityTypeBuilder<WorkflowTask> builder)
    {
        builder.ToTable("WorkflowTask", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.TaskStatus).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Remarks).HasMaxLength(2000);

        // TaskStatusGroup is a computed persisted column — never written by EF
        builder.Property<string>("TaskStatusGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_TASK_STATUS' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);

        builder.HasIndex(e => new { e.AssignedToEmployeeId, e.TaskStatus });
        builder.HasIndex(e => e.WorkflowInstanceId);
        builder.HasIndex(e => e.WorkflowStepId);

        // AssignedToEmployeeId, DelegatedFromEmployeeId, ActionBy: cross-schema FKs to employee.Employee

        // Instance nav configured from WorkflowInstanceConfiguration

        // Step nav (no cascade — instance → step already has one)
        builder.HasOne(e => e.Step)
            .WithMany()
            .HasForeignKey(e => e.WorkflowStepId)
            .OnDelete(DeleteBehavior.Restrict);

        // StepApprover nav
        builder.HasOne(e => e.StepApprover)
            .WithMany()
            .HasForeignKey(e => e.WorkflowStepApproverId)
            .OnDelete(DeleteBehavior.Restrict);

        // Self-referencing delegation chain
        builder.HasOne(e => e.ParentTask)
            .WithMany(e => e.ChildTasks)
            .HasForeignKey(e => e.ParentWorkflowTaskId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class WorkflowActionHistoryConfiguration : IEntityTypeConfiguration<WorkflowActionHistory>
{
    public void Configure(EntityTypeBuilder<WorkflowActionHistory> builder)
    {
        builder.ToTable("WorkflowActionHistory", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.WorkflowActionType).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Remarks).HasMaxLength(2000);
        builder.Property(e => e.FromWorkflowStatus).HasMaxLength(50);
        builder.Property(e => e.ToWorkflowStatus).HasMaxLength(50);

        // Two independent computed columns for FK into shared.StatusLookup (v2 fix to avoid collision)
        builder.Property<string>("FromWorkflowStatusGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);
        builder.Property<string>("ToWorkflowStatusGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_STATUS' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);
        builder.Property<string>("WorkflowActionTypeGroup")
            .HasComputedColumnSql("CAST('WORKFLOW_ACTION_TYPE' AS NVARCHAR(50))", stored: true)
            .HasMaxLength(50);

        builder.HasIndex(e => e.WorkflowInstanceId);
        builder.HasIndex(e => e.WorkflowTaskId);

        // ActionBy: cross-schema FK to employee.Employee — ID only, no EF relationship
        // Instance nav configured from WorkflowInstanceConfiguration

        // Task nav (optional — null for system actions)
        builder.HasOne(e => e.Task)
            .WithMany()
            .HasForeignKey(e => e.WorkflowTaskId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // Step nav (optional)
        builder.HasOne(e => e.Step)
            .WithMany()
            .HasForeignKey(e => e.WorkflowStepId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class WorkflowAssignmentSummaryConfiguration : IEntityTypeConfiguration<WorkflowAssignmentSummary>
{
    public void Configure(EntityTypeBuilder<WorkflowAssignmentSummary> builder)
    {
        builder.HasNoKey();
        builder.ToView("vwWorkflowAssignment", "workflow");
        builder.Property(e => e.WorkflowModuleId);
        builder.Property(e => e.ModuleCode);
        builder.Property(e => e.WorkflowDefinitionId);
        builder.Property(e => e.WorkflowCode);
        builder.Property(e => e.WorkflowName);
        builder.Property(e => e.VersionNo);
        builder.Property(e => e.WorkflowAssignmentId);
        builder.Property(e => e.ScopeTypeId);
        builder.Property(e => e.ScopeReferenceId);
        builder.Property(e => e.PriorityOrder);
    }
}

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.ToTable("OutboxMessages", "workflow");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EventType).HasMaxLength(500).IsRequired();
        builder.Property(e => e.Exchange).HasMaxLength(200).IsRequired();
        builder.Property(e => e.RoutingKey).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Status).HasMaxLength(50).IsRequired();
    }
}
