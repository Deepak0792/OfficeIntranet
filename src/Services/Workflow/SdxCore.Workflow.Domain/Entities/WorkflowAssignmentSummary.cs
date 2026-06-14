using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.Workflow.Domain.Entities
{
    public class WorkflowAssignmentSummary
    {
        public Guid WorkflowModuleId { get; set; }

        public string ModuleCode { get; set; } = string.Empty;

        public Guid WorkflowDefinitionId { get; set; }

        public string WorkflowCode { get; set; } = string.Empty;

        public string WorkflowName { get; set; } = string.Empty;

        public short VersionNo { get; set; }

        public Guid WorkflowAssignmentId { get; set; }

        public Guid ScopeTypeId { get; set; }

        public Guid ScopeReferenceId { get; set; }

        public short PriorityOrder { get; set; }

        public bool IsActive { get; set; }

        public DateOnly? EffectiveFrom { get; set; }

        public DateOnly? EffectiveTo { get; set; }
    }
}
