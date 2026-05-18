namespace SdxCore.Time.Domain.Entities;
public abstract class BaseEntity {
    public long Id { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
