namespace SdxCore.Attendance.Application.Configuration;
public sealed class AttendanceProcessingOptions
{
    public const string SectionName = "AttendanceProcessing";
    public AttendanceProcessorOptions AttendanceLogProcessor { get; set; } = new();

    public AttendanceProcessorOptions AttendanceCalculation { get; set; } = new();

    public AttendanceProcessorOptions AutoCheckout { get; set; } = new();

    public AttendanceProcessorOptions AttendanceFinalizer { get; set; } = new();

    public AttendanceProcessorOptions RosterGeneration { get; set; } = new();

    public AttendanceProcessorOptions AttendancePending { get; set; } = new();
}
