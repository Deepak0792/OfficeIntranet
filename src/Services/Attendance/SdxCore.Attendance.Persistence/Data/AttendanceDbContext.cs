using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Interceptors;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Interceptors;

namespace SdxCore.Attendance.Persistence.Data;

public class AttendanceDbContext(
    DbContextOptions<AttendanceDbContext> options,
    OutboxSaveChangesInterceptor outboxInterceptor,
    AttendanceWorkflowOutboxInterceptor workflowInterceptor)
    : SdxDbContext(options)
{
    // Lookups
    public DbSet<AttendanceStatus> AttendanceStatuses { get; set; } = null!;

    // Shift management
    public DbSet<Shift> Shifts { get; set; } = null!;
    public DbSet<ShiftAssignment> ShiftAssignments { get; set; } = null!;
    public DbSet<RotationShift> RotationShifts { get; set; } = null!;
    public DbSet<RotationShiftDetail> RotationShiftDetails { get; set; } = null!;
    public DbSet<RotationShiftAssignment> RotationShiftAssignments { get; set; } = null!;

    // Roster
    public DbSet<EmployeeShiftRoster> EmployeeShiftRosters { get; set; } = null!;
    public DbSet<EmployeeRosterGenerationTracker> EmployeeRosterGenerationTrackers { get; set; } = null!;

    // Attendance
    public DbSet<WorkSession> WorkSessions { get; set; } = null!;
    public DbSet<AttendanceRecord> AttendanceRecords { get; set; } = null!;
    public DbSet<AttendanceLog> AttendanceLogs { get; set; } = null!;
    public DbSet<MobileAttendanceLog> MobileAttendanceLogs { get; set; } = null!;

    // Leave
    public DbSet<LeaveType> LeaveTypes { get; set; } = null!;
    public DbSet<LeaveRequest> LeaveRequests { get; set; } = null!;
    public DbSet<LeaveBalance> LeaveBalances { get; set; } = null!;

    // Comp-Off
    public DbSet<CompOffType> CompOffTypes { get; set; } = null!;
    public DbSet<CompOffBalance> CompOffBalances { get; set; } = null!;

    // Regularization
    public DbSet<AttendanceRegularization> AttendanceRegularizations { get; set; } = null!;

    // Holiday
    public DbSet<HolidayCalendar> HolidayCalendars { get; set; } = null!;
    public DbSet<HolidayType> HolidayTypes { get; set; } = null!;
    public DbSet<Holiday> Holidays { get; set; } = null!;
    public DbSet<HolidayCalendarAssignment> HolidayCalendarAssignments { get; set; } = null!;

    // Work Week
    public DbSet<WorkWeekPolicy> WorkWeekPolicies { get; set; } = null!;
    public DbSet<WorkWeekPolicyDay> WorkWeekPolicyDays { get; set; } = null!;
    public DbSet<WorkWeekPolicyAssignment> WorkWeekPolicyAssignments { get; set; } = null!;

    // Shift Swap
    public DbSet<ShiftSwapRequest> ShiftSwapRequests { get; set; } = null!;

    // Outbox
    public DbSet<OutboxMessage> OutboxMessages { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.AddInterceptors(outboxInterceptor, workflowInterceptor);

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.HasDefaultSchema("attendance");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AttendanceDbContext).Assembly);
    }
}
