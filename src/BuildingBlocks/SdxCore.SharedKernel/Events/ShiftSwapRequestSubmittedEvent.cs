namespace SdxCore.SharedKernel.Events;

public sealed record ShiftSwapRequestSubmittedEvent(
    Guid ShiftSwapRequestId,
    Guid RequesterEmployeeId,
    Guid TargetEmployeeId,
    Guid RequesterRosterId,
    Guid TargetRosterId,
    string ModuleCode,
    DateTime CreatedAt
);