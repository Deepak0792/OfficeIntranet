namespace SdxCore.SharedKernel.Entities;
public interface IAuditableEntity
{
    DateTime CreatedAt     { get; set; }
    int?     CreatedBy     { get; set; }
    DateTime LastUpdatedAt { get; set; }
    int?     LastUpdatedBy { get; set; }
}
