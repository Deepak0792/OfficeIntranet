using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class Designation : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string DesignationCode { get; set; }
    public required string DesignationName { get; set; }
    public string? Grade { get; set; }
    public bool IsActive { get; set; } = true;
}