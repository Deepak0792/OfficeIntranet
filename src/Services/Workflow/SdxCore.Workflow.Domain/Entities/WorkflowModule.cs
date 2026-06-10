using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowModule : BaseAuditEntity<Guid>
{
    public string ModuleCode { get; set; } = null!;
    public string ModuleName { get; set; } = null!;
    public string EntityName { get; set; } = null!;  // Logical entity (LeaveRequest, etc.)
    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<WorkflowDefinition> Definitions { get; set; } = [];
}
