namespace SdxCore.SharedKernel.Entities;

/// <summary>
/// Full audit entity: CreatedAt, CreatedBy, LastUpdatedAt, LastUpdatedBy.
/// Injected automatically by BaseRepository via IRequestContext.
/// </summary>
public abstract class BaseAuditEntity<TKey> : BaseEntity<TKey>
{
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public int? LastUpdatedBy { get; set; }
}