using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class MobileAttendanceLog : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.GeoFence — ID only, no nav prop.</summary>
    public Guid? GeoFenceId { get; set; }

    public DateTime PunchTime { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public bool IsInsideGeoFence { get; set; }
    public string? DeviceInfo { get; set; }
    public bool IsActive { get; set; } = true;
}
