using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.Workflow.Domain.Entities
{
    public class WorkflowAssignmentSummary
    {
        public short WorkflowModuleId { get; set; }

        public string ModuleCode { get; set; } = string.Empty;

        public short WorkflowDefinitionId { get; set; }

        public string WorkflowCode { get; set; } = string.Empty;

        public string WorkflowName { get; set; } = string.Empty;

        public short VersionNo { get; set; }

        public short WorkflowAssignmentId { get; set; }

        public short ScopeTypeId { get; set; }

        public int ScopeReferenceId { get; set; }

        public short PriorityOrder { get; set; }
    }
}
