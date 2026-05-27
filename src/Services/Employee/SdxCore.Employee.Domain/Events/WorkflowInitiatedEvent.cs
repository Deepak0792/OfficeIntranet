namespace SdxCore.Employee.Domain.Events;

public class WorkflowInitiatedEvent
{
    public string ModuleName { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public int InitiatorEmployeeId { get; set; }
    public string ActionPayload { get; set; } = string.Empty;
}
