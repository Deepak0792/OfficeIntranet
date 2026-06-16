namespace SdxCore.SharedKernel.Events;

public sealed record AttendanceRegularizationSubmittedEvent(
    Guid RegularizationId,
    Guid EmployeeId,
    string ModuleCode,
    DateOnly AttendanceDate,
    DateTime? RequestedCheckIn,
    DateTime? RequestedCheckOut,
    string? Reason,
    DateTime CreatedAt
);