namespace SdxCore.Attendance.Application.DTOs.Leave.Request;

public record UpdateLeaveStatusRequest(string Status, Guid? ActionBy = null, string? Remarks = null);
