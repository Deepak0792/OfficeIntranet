namespace SdxCore.Attendance.Application.DTOs.WorkWeek.Response;

public class WorkWeekPolicyResponse
{
    public Guid Id { get; set; }

    public string PolicyCode { get; set; } = null!;

    public string PolicyName { get; set; } = null!;

    public bool IsDefault { get; set; }

    public IReadOnlyCollection<WorkWeekDayResponse> Days { get; set; }
        = [];
}