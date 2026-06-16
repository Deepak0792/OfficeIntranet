namespace SdxCore.Attendance.Application.DTOs.Roster.Response;

public record RosterResponse(
    Guid Id,
    Guid EmployeeId,
    DateOnly RosterDate,
    Guid? ShiftId,
    string? ShiftName,
    bool IsOffDay,
    bool IsHoliday,
    DateTime? PlannedStartTime,
    DateTime? PlannedEndTime,
    bool IsLocked,
    string? Remarks);

public record RosterGenerationResult(
    int TotalEmployees,
    int TotalRows,
    int Skipped,
    List<string> Errors);

public record RosterUploadResult(
    int TotalRows,
    int Created,
    int Updated,
    int Skipped,
    List<string> Errors);
