using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.Workflow.Domain.Exceptions;

public class WorkflowResolutionException(int initiatorEmployeeId, string moduleCode, string workflowCode)
    : Exception($"No workflow mapping found for employee {initiatorEmployeeId}, " +
                $"module '{moduleCode}', workflow '{workflowCode}'.")
{
}