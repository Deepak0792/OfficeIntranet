$domainDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Domain\Entities"
New-Item -ItemType Directory -Force -Path $domainDir | Out-Null

$baseEntityCode = @"
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using SdxCore.Common.Models;

namespace SdxCore.Attendance.Domain.Entities;

public abstract class BaseEntity : IHasDomainEvents
{    
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public int? LastUpdatedBy { get; set; }

    private readonly List<object> _domainEvents = new();

    [NotMapped]
    public IReadOnlyCollection<object> DomainEvents => _domainEvents.AsReadOnly();

    public void AddDomainEvent(object domainEvent)
    {
        _domainEvents.Add(domainEvent);
    }

    public void RemoveDomainEvent(object domainEvent)
    {
        _domainEvents.Remove(domainEvent);
    }

    public void ClearDomainEvents()
    {
        _domainEvents.Clear();
    }

    public IReadOnlyCollection<object> GetDomainEvents() => _domainEvents.AsReadOnly();
}
"@
Set-Content -Path "$domainDir\BaseEntity.cs" -Value $baseEntityCode

$shiftCode = @"
using System;
using System.Collections.Generic;

namespace SdxCore.Attendance.Domain.Entities;

public class Shift : BaseEntity
{
    public short Id { get; set; }
    public string ShiftCode { get; set; } = string.Empty;
    public string ShiftName { get; set; } = string.Empty;
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public short BreakDurationMinutes { get; set; } = 0;
    public short GraceInMinutes { get; set; } = 0;
    public short GraceOutMinutes { get; set; } = 0;
    public short? MinimumWorkingMinutes { get; set; }
    public short? MaximumWorkingMinutes { get; set; }
    public short AttendanceFinalizeBufferMinutes { get; set; } = 240;
    public short? MaxAllowedCheckoutDelayMinutes { get; set; }
    public bool IsNightShift { get; set; } = false;
    public bool CrossesMidnight { get; set; } = false;
    public bool IsFlexible { get; set; } = false;
    public bool AllowOvertime { get; set; } = true;
}
"@
Set-Content -Path "$domainDir\Shift.cs" -Value $shiftCode

$workSessionCode = @"
using System;

namespace SdxCore.Attendance.Domain.Entities;

public class WorkSession : BaseEntity
{
    public long Id { get; set; }
    public int EmployeeId { get; set; }
    public long? EmployeeShiftId { get; set; }
    public DateTime SessionDate { get; set; }
    public DateTime CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public int? WorkedMinutes { get; set; }
}
"@
Set-Content -Path "$domainDir\WorkSession.cs" -Value $workSessionCode

$attendanceRecordCode = @"
using System;

namespace SdxCore.Attendance.Domain.Entities;

public class AttendanceRecord : BaseEntity
{
    public long Id { get; set; }
    public int EmployeeId { get; set; }
    public long? EmployeeShiftId { get; set; }
    public long? WorkSessionId { get; set; }
    public DateTime AttendanceDate { get; set; }
    public short? ShiftId { get; set; }
    public string? AttendanceStatus { get; set; }
    public DateTime? CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public short? LateByMinutes { get; set; }
    public short? EarlyExitMinutes { get; set; }
    public short? WorkedMinutes { get; set; }
    public short BreakMinutes { get; set; } = 0;
    public short OvertimeMinutes { get; set; } = 0;
    public bool IsNightShift { get; set; } = false;
    public bool IsCrossDayAttendance { get; set; } = false;
    public bool IsWeeklyOff { get; set; } = false;
    public bool IsHoliday { get; set; } = false;
    public bool IsOnLeave { get; set; } = false;
    public bool IsManualEntry { get; set; } = false;
    public bool IsAutoProcessed { get; set; } = true;
    public bool IsAttendanceLocked { get; set; } = false;
    public string? Remarks { get; set; }
    public int? ApprovedBy { get; set; }
    public DateTime? ApprovedAt { get; set; }
}
"@
Set-Content -Path "$domainDir\AttendanceRecord.cs" -Value $attendanceRecordCode

$leaveTypeCode = @"
namespace SdxCore.Attendance.Domain.Entities;

public class LeaveType : BaseEntity
{
    public short Id { get; set; }
    public string LeaveCode { get; set; } = string.Empty;
    public string LeaveName { get; set; } = string.Empty;
    public bool IsPaid { get; set; } = true;
    public decimal? MaxDaysPerYear { get; set; }
    public bool AllowCarryForward { get; set; } = false;
    public bool RequiresApproval { get; set; } = true;
    public bool AllowHalfDay { get; set; } = true;
}
"@
Set-Content -Path "$domainDir\LeaveType.cs" -Value $leaveTypeCode

$leaveRequestCode = @"
using System;

namespace SdxCore.Attendance.Domain.Entities;

public class LeaveRequest : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public string LeaveStatus { get; set; } = string.Empty;
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public decimal TotalDays { get; set; }
    public bool IsHalfDay { get; set; } = false;
    public string? HalfDaySession { get; set; }
    public string? Reason { get; set; }
    public int? WorkflowInstanceId { get; set; }
    public string? Remarks { get; set; }
    public int? ApprovedBy { get; set; }
    public DateTime? ApprovedAt { get; set; }
}
"@
Set-Content -Path "$domainDir\LeaveRequest.cs" -Value $leaveRequestCode

$leaveBalanceCode = @"
namespace SdxCore.Attendance.Domain.Entities;

public class LeaveBalance : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public short BalanceYear { get; set; }
    public decimal OpeningBalance { get; set; } = 0;
    public decimal Allocated { get; set; } = 0;
    public decimal Availed { get; set; } = 0;
    public decimal Encashed { get; set; } = 0;
    public decimal CarryForward { get; set; } = 0;
}
"@
Set-Content -Path "$domainDir\LeaveBalance.cs" -Value $leaveBalanceCode

$shiftRosterCode = @"
using System;

namespace SdxCore.Attendance.Domain.Entities;

public class EmployeeShiftRoster : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public DateTime RosterDate { get; set; }
    public short? ShiftId { get; set; }
    public bool IsOffDay { get; set; } = false;
    public bool IsHoliday { get; set; } = false;
    public DateTime? PlannedStartTime { get; set; }
    public DateTime? PlannedEndTime { get; set; }
    public DateTime? ActualStartTime { get; set; }
    public DateTime? ActualEndTime { get; set; }
    public string? Remarks { get; set; }
    public bool IsLocked { get; set; } = false;
}
"@
Set-Content -Path "$domainDir\EmployeeShiftRoster.cs" -Value $shiftRosterCode

Write-Output "Successfully generated key Attendance Domain Entities."
