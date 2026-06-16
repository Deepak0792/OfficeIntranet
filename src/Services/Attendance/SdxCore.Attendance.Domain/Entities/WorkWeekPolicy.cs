using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class WorkWeekPolicy : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string PolicyCode { get; set; }
    public required string PolicyName { get; set; }
    public string? Description { get; set; }
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public ICollection<WorkWeekPolicyDay> Days { get; set; } = [];
}
