namespace SdxCore.SharedKernel.Entities;

/// <summary>
/// Base entity with PK only — for tables that have a separate audit pattern
/// or are managed by the outbox/event system.
/// </summary>
public abstract class BaseEntity<TKey>
{
    public TKey Id { get; set; } = default!;
}
