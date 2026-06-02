namespace SdxCore.SharedKernel.Events;
public sealed record EntityChangedEvent(
    string Id,
    string EntityName,
    string Operation,
    DateTime OccurredOnUtc);
