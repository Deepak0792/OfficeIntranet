namespace SdxCore.SharedKernel.Events;

public sealed record CompOffRedemptionSubmittedEvent(
    Guid CompOffBalanceId,
    Guid EmployeeId,
    string ModuleCode,
    decimal TotalDays,
    DateTime CreatedAt
);