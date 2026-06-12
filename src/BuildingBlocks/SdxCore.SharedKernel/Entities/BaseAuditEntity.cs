using SdxCore.SharedKernel.Abstractions;

namespace SdxCore.SharedKernel.Entities;

/// <summary>
/// Full audit entity: CreatedAt, CreatedBy, LastUpdatedAt, LastUpdatedBy.
/// Injected automatically by BaseRepository via IRequestContext.
/// </summary>
public abstract class BaseAuditEntity<TKey> : BaseEntity<TKey>, IAuditableEntity
{
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public Guid? LastUpdatedBy { get; set; }
}