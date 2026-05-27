$dataDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Persistence\Data"
$configDir = "$dataDir\Configurations"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$dbContextCode = @"
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
"@
Set-Content -Path "$dataDir\WorkflowDbContext.cs" -Value $dbContextCode

$instanceConfig = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace SdxCore.Workflow.Persistence.Data.Configurations;

public class WorkflowInstanceConfiguration : IEntityTypeConfiguration<Domain.Entities.WorkflowInstance>
{
    public void Configure(EntityTypeBuilder<Domain.Entities.WorkflowInstance> builder)
    {
        builder.ToTable("WorkflowInstance");
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.WorkflowStatus).IsRequired().HasMaxLength(50);
        
        builder.HasIndex(e => new { e.WorkflowModuleId, e.ReferenceTransactionId });
        builder.HasIndex(e => e.CreatedBy);
        builder.HasIndex(e => e.CurrentWorkflowStepId);
    }
}
"@
Set-Content -Path "$configDir\WorkflowInstanceConfiguration.cs" -Value $instanceConfig

Write-Output "Successfully generated Workflow DbContext and Configurations."
