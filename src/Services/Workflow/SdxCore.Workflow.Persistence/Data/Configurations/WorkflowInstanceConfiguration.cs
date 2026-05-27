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
