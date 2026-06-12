namespace SdxCore.SharedKernel.Abstractions;
public interface IAuditableEntity
{
    DateTime CreatedAt { get; set; }
    Guid? CreatedBy { get; set; }
    DateTime LastUpdatedAt { get; set; }
    Guid? LastUpdatedBy { get; set; }
}
