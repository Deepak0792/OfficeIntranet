namespace SdxCore.Time.Domain.Entities;
public abstract class BaseEntity
{    
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; }
    public int LastUpdatedBy { get; set; }
}
