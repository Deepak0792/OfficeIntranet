using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class LeaveType : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string LeaveCode { get; set; }
    public required string LeaveName { get; set; }
    public bool IsPaid { get; set; }
    public decimal? MaxDaysPerYear { get; set; }
    public bool AllowCarryForward { get; set; }
    public bool RequiresApproval { get; set; } = true;
    public bool AllowHalfDay { get; set; }

    /// <summary>Workflow code used to initiate the approval workflow (e.g. "STANDARD_LEAVE_V1").</summary>
    public string? WorkflowCode { get; set; }

    public bool IsActive { get; set; } = true;
}
