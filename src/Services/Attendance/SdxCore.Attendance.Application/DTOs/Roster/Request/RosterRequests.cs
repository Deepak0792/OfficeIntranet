namespace SdxCore.Attendance.Application.DTOs.Roster.Request;

public record GenerateRosterRequest(
    DateOnly FromDate,
    DateOnly ToDate,
    string GenerationType,
    IEnumerable<Guid>? EmployeeIds = null,
    Guid? ScopeTypeId = null,
    Guid? ScopeReferenceId = null,
    bool ForceRegenerate = false,
    bool LockAfterGenerate = false,
    string? Remarks = null);

public record UpdateRosterRequest(
    Guid? ShiftId,
    bool IsOffDay,
    bool IsHoliday,
    DateTime? PlannedStartTime,
    DateTime? PlannedEndTime,
    bool IsLocked,
    string? Remarks);

public record RosterUploadRequest(
    DateOnly FromDate,
    DateOnly ToDate,
    string GenerationType,
    List<RosterRowRequest> Rows,
    bool LockAfterUpload = true,
    string? Remarks = null);

public record RosterRowRequest(
    Guid EmployeeId,
    DateOnly Date,
    Guid? ShiftId,
    bool IsOffDay,
    bool IsHoliday,
    string? Remarks);
