$domainDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Domain\Events"
New-Item -ItemType Directory -Force -Path $domainDir | Out-Null

$eventsCode = @"
namespace SdxCore.Workflow.Domain.Events;

public class WorkflowStatusChangedEvent
{
    public int WorkflowInstanceId { get; set; }
    public string NewStatus { get; set; } = string.Empty;
}

public class WorkflowTaskAssignedEvent
{
    public int WorkflowTaskId { get; set; }
    public int WorkflowInstanceId { get; set; }
    public int AssignedToEmployeeId { get; set; }
}
"@
Set-Content -Path "$domainDir\WorkflowEvents.cs" -Value $eventsCode
