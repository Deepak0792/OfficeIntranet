namespace SdxCore.Attendance.Application.DTOs.RosterPolicy.Response;

public class ResolvedRosterGenerationPolicy
{
    public Guid PolicyId { get; set; }

    public string PolicyCode { get; set; } = null!;

    public string PolicyName { get; set; } = null!;

    public string GenerationType { get; set; } = null!;

    public short GenerateDaysBefore { get; set; }

    public bool AutoGenerate { get; set; }

    public bool LockAfterGeneration { get; set; }
}