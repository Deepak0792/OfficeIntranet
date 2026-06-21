using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Persistence.Data.Configurations;

/// <summary>
/// Consolidates all IEntityTypeConfiguration classes for the attendance schema.
/// Applied via ApplyConfigurationsFromAssembly in AttendanceDbContext.
///
/// Schema boundary rule:
///   - Navigation properties are ONLY configured for entities within the attendance schema.
///   - Cross-schema FKs (employee.*, time.*, workflow.*, shared.*) are stored as plain IDs.
///     EF is NOT told about them to avoid cross-schema constraint conflicts.
/// </summary>

public sealed class AttendanceStatusConfiguration : IEntityTypeConfiguration<AttendanceStatus>
{
    public void Configure(EntityTypeBuilder<AttendanceStatus> builder)
    {
        builder.ToTable("AttendanceStatus");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.StatusCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.StatusName).HasMaxLength(200).IsRequired();
    }
}

public sealed class ShiftConfiguration : IEntityTypeConfiguration<Shift>
{
    public void Configure(EntityTypeBuilder<Shift> builder)
    {
        builder.ToTable("Shift");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.ShiftCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.ShiftName).HasMaxLength(200).IsRequired();
    }
}

public sealed class ShiftAssignmentConfiguration : IEntityTypeConfiguration<ShiftAssignment>
{
    public void Configure(EntityTypeBuilder<ShiftAssignment> builder)
    {
        builder.ToTable("ShiftAssignment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // Intra-schema: ShiftId → Shift
        builder.HasOne(e => e.Shift)
            .WithMany()
            .HasForeignKey(e => e.ShiftId)
            .OnDelete(DeleteBehavior.Restrict);

        // ScopeTypeId, ScopeReferenceId: cross-schema — no EF relationship
    }
}

public sealed class RotationShiftConfiguration : IEntityTypeConfiguration<RotationShift>
{
    public void Configure(EntityTypeBuilder<RotationShift> builder)
    {
        builder.ToTable("RotationShift");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.RotationCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.RotationName).HasMaxLength(200).IsRequired();

        builder.HasMany(e => e.Details)
            .WithOne(d => d.RotationShift)
            .HasForeignKey(d => d.RotationShiftId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class RotationShiftDetailConfiguration : IEntityTypeConfiguration<RotationShiftDetail>
{
    public void Configure(EntityTypeBuilder<RotationShiftDetail> builder)
    {
        builder.ToTable("RotationShiftDetail");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.HasIndex(e => new { e.RotationShiftId, e.SequenceNo }).IsUnique();

        // Intra-schema: nullable ShiftId → Shift
        builder.HasOne(e => e.Shift)
            .WithMany()
            .HasForeignKey(e => e.ShiftId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // RotationShift relationship configured from RotationShiftConfiguration
    }
}

public sealed class RotationShiftAssignmentConfiguration : IEntityTypeConfiguration<RotationShiftAssignment>
{
    public void Configure(EntityTypeBuilder<RotationShiftAssignment> builder)
    {
        builder.ToTable("RotationShiftAssignment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.HasOne(e => e.RotationShift)
            .WithMany()
            .HasForeignKey(e => e.RotationShiftId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class EmployeeShiftRosterConfiguration : IEntityTypeConfiguration<EmployeeShiftRoster>
{
    public void Configure(EntityTypeBuilder<EmployeeShiftRoster> builder)
    {
        builder.ToTable("EmployeeShiftRoster");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.Remarks).HasMaxLength(500);

        builder.HasIndex(e => new { e.EmployeeId, e.RosterDate }).IsUnique();

        // Intra-schema: nullable ShiftId → Shift
        builder.HasOne(e => e.Shift)
            .WithMany()
            .HasForeignKey(e => e.ShiftId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        // EmployeeId: cross-schema FK to employee.Employee — no EF relationship
    }
}

public sealed class EmployeeRosterGenerationTrackerConfiguration : IEntityTypeConfiguration<EmployeeRosterGenerationTracker>
{
    public void Configure(EntityTypeBuilder<EmployeeRosterGenerationTracker> builder)
    {
        builder.ToTable("EmployeeRosterGenerationTracker");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.GenerationType).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Remarks).HasMaxLength(500);

        builder.HasIndex(e => new { e.EmployeeId, e.RosterYear, e.RosterMonth, e.GenerationType }).IsUnique();

        // GenerationTypeGroup is a computed/persisted column — EF should not write to it
        builder.Property(e => e.GenerationTypeGroup)
            .HasComputedColumnSql("CAST('ROSTER_GENERATION_TYPE' AS NVARCHAR(50))", stored: true);
    }
}

public sealed class WorkSessionConfiguration : IEntityTypeConfiguration<WorkSession>
{
    public void Configure(EntityTypeBuilder<WorkSession> builder)
    {
        builder.ToTable("WorkSession");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // Intra-schema: nullable EmployeeShiftRosterId → EmployeeShiftRoster
        builder.HasOne(e => e.EmployeeShiftRoster)
            .WithMany()
            .HasForeignKey(e => e.EmployeeShiftRosterId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class AttendanceRecordConfiguration : IEntityTypeConfiguration<AttendanceRecord>
{
    public void Configure(EntityTypeBuilder<AttendanceRecord> builder)
    {
        builder.ToTable("AttendanceRecord");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.Remarks).HasMaxLength(500);

        builder.HasIndex(e => new { e.EmployeeId, e.AttendanceDate }).IsUnique();

        builder.HasOne(e => e.EmployeeShiftRoster)
            .WithMany()
            .HasForeignKey(e => e.EmployeeShiftRosterId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        builder.HasOne(e => e.Shift)
            .WithMany()
            .HasForeignKey(e => e.ShiftId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);

        builder.HasOne(e => e.AttendanceStatus)
            .WithMany()
            .HasForeignKey(e => e.AttendanceStatusId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public sealed class AttendanceLogConfiguration : IEntityTypeConfiguration<AttendanceLog>
{
    public void Configure(EntityTypeBuilder<AttendanceLog> builder)
    {
        builder.ToTable("AttendanceLog");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.PunchType).HasMaxLength(20).IsRequired();
        builder.Property(e => e.DeviceId).HasMaxLength(100);
        builder.Property(e => e.Location).HasMaxLength(500);
    }
}

public sealed class MobileAttendanceLogConfiguration : IEntityTypeConfiguration<MobileAttendanceLog>
{
    public void Configure(EntityTypeBuilder<MobileAttendanceLog> builder)
    {
        builder.ToTable("MobileAttendanceLog");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.Latitude).HasPrecision(10, 7);
        builder.Property(e => e.Longitude).HasPrecision(10, 7);
        builder.Property(e => e.DeviceInfo).HasMaxLength(500);
        // GeoFenceId: cross-schema FK to time.GeoFence — no EF relationship
    }
}

public sealed class LeaveTypeConfiguration : IEntityTypeConfiguration<LeaveType>
{
    public void Configure(EntityTypeBuilder<LeaveType> builder)
    {
        builder.ToTable("LeaveType");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.LeaveCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.LeaveName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.WorkflowCode).HasMaxLength(200);
        builder.Property(e => e.MaxDaysPerYear).HasPrecision(6, 2);
    }
}

public sealed class LeaveRequestConfiguration : IEntityTypeConfiguration<LeaveRequest>
{
    public void Configure(EntityTypeBuilder<LeaveRequest> builder)
    {
        builder.ToTable("LeaveRequest");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.LeaveStatus).HasMaxLength(50).IsRequired();
        builder.Property(e => e.HalfDaySession).HasMaxLength(20);
        builder.Property(e => e.Reason).HasMaxLength(1000);
        builder.Property(e => e.Remarks).HasMaxLength(1000);
        builder.Property(e => e.TotalDays).HasPrecision(6, 2);

        // LeaveStatusGroup is a computed/persisted column — EF should not write to it
        builder.Property(e => e.LeaveStatusGroup)
            .HasComputedColumnSql("CAST('LEAVE_STATUS' AS NVARCHAR(50))", stored: true);

        // Intra-schema: LeaveTypeId → LeaveType
        builder.HasOne(e => e.LeaveType)
            .WithMany()
            .HasForeignKey(e => e.LeaveTypeId)
            .OnDelete(DeleteBehavior.Restrict);

        // EmployeeId, WorkflowInstanceId, ApprovedBy: cross-schema — no EF relationship
    }
}

public sealed class LeaveBalanceConfiguration : IEntityTypeConfiguration<LeaveBalance>
{
    public void Configure(EntityTypeBuilder<LeaveBalance> builder)
    {
        builder.ToTable("LeaveBalance");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.OpeningBalance).HasPrecision(6, 2);
        builder.Property(e => e.Allocated).HasPrecision(6, 2);
        builder.Property(e => e.Availed).HasPrecision(6, 2);
        builder.Property(e => e.Encashed).HasPrecision(6, 2);
        builder.Property(e => e.CarryForward).HasPrecision(6, 2);

        builder.HasIndex(e => new { e.EmployeeId, e.LeaveTypeId, e.BalanceYear }).IsUnique();

        // ClosingBalance is a non-stored computed column — EF should not write to it
        builder.Property(e => e.ClosingBalance)
            .HasComputedColumnSql("(OpeningBalance + Allocated + CarryForward - Availed - Encashed)", stored: false);

        builder.HasOne(e => e.LeaveType)
            .WithMany()
            .HasForeignKey(e => e.LeaveTypeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class CompOffTypeConfiguration : IEntityTypeConfiguration<CompOffType>
{
    public void Configure(EntityTypeBuilder<CompOffType> builder)
    {
        builder.ToTable("CompOffType");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.CompOffTypeCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.CompOffTypeName).HasMaxLength(200).IsRequired();
    }
}

public sealed class CompOffBalanceConfiguration : IEntityTypeConfiguration<CompOffBalance>
{
    public void Configure(EntityTypeBuilder<CompOffBalance> builder)
    {
        builder.ToTable("CompOffBalance");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.TotalDays).HasPrecision(10, 2);
        builder.Property(e => e.AvailedDays).HasPrecision(10, 2);

        // RemainingDays is a non-stored computed column — EF should not write to it
        builder.Property(e => e.RemainingDays)
            .HasComputedColumnSql("(TotalDays - AvailedDays)", stored: false);

        builder.HasOne(e => e.CompOffType)
            .WithMany()
            .HasForeignKey(e => e.CompOffTypeId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.AttendanceRecord)
            .WithMany()
            .HasForeignKey(e => e.AttendanceRecordId)
            .OnDelete(DeleteBehavior.Restrict)
            .IsRequired(false);
    }
}

public class CompOffAvailmentConfiguration : IEntityTypeConfiguration<CompOffAvailment>
{
    public void Configure(EntityTypeBuilder<CompOffAvailment> builder)
    {
        builder.ToTable("CompOffAvailment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.DaysAvailed).HasPrecision(10, 2);

        builder.HasOne(e => e.LeaveRequest)
            .WithMany()
            .HasForeignKey(e => e.LeaveRequestId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.CompOffBalance)
            .WithMany()
            .HasForeignKey(e => e.CompOffBalanceId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class AttendanceRegularizationConfiguration : IEntityTypeConfiguration<AttendanceRegularization>
{
    public void Configure(EntityTypeBuilder<AttendanceRegularization> builder)
    {
        builder.ToTable("AttendanceRegularization");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.RegularizationStatus).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Reason).HasMaxLength(1000);
        builder.Property(e => e.Remarks).HasMaxLength(1000);

        // RegularizationStatusGroup is a computed/persisted column — EF should not write to it
        builder.Property(e => e.RegularizationStatusGroup)
            .HasComputedColumnSql("CAST('ATTENDANCE_REGULARIZATION_STATUS' AS NVARCHAR(50))", stored: true);
    }
}

public sealed class HolidayCalendarConfiguration : IEntityTypeConfiguration<HolidayCalendar>
{
    public void Configure(EntityTypeBuilder<HolidayCalendar> builder)
    {
        builder.ToTable("HolidayCalendar");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.CalendarCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.CalendarName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);
    }
}

public sealed class HolidayTypeConfiguration : IEntityTypeConfiguration<HolidayType>
{
    public void Configure(EntityTypeBuilder<HolidayType> builder)
    {
        builder.ToTable("HolidayType");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.HolidayTypeCode).HasMaxLength(50).IsRequired();
        builder.Property(e => e.HolidayTypeName).HasMaxLength(200).IsRequired();
    }
}

public sealed class HolidayConfiguration : IEntityTypeConfiguration<Holiday>
{
    public void Configure(EntityTypeBuilder<Holiday> builder)
    {
        builder.ToTable("Holiday");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.HolidayCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.HolidayName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.HalfDaySession).HasMaxLength(20);
        builder.Property(e => e.Description).HasMaxLength(1000);

        builder.HasOne(e => e.HolidayCalendar)
            .WithMany()
            .HasForeignKey(e => e.HolidayCalendarId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.HolidayType)
            .WithMany()
            .HasForeignKey(e => e.HolidayTypeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class HolidayCalendarAssignmentConfiguration : IEntityTypeConfiguration<HolidayCalendarAssignment>
{
    public void Configure(EntityTypeBuilder<HolidayCalendarAssignment> builder)
    {
        builder.ToTable("HolidayCalendarAssignment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.MergeStrategy).HasMaxLength(20).IsRequired();

        builder.HasOne(e => e.HolidayCalendar)
            .WithMany()
            .HasForeignKey(e => e.HolidayCalendarId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class WorkWeekPolicyConfiguration : IEntityTypeConfiguration<WorkWeekPolicy>
{
    public void Configure(EntityTypeBuilder<WorkWeekPolicy> builder)
    {
        builder.ToTable("WorkWeekPolicy");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.PolicyCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.PolicyName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);

        builder.HasMany(e => e.Days)
            .WithOne(d => d.WorkWeekPolicy)
            .HasForeignKey(d => d.WorkWeekPolicyId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class WorkWeekPolicyDayConfiguration : IEntityTypeConfiguration<WorkWeekPolicyDay>
{
    public void Configure(EntityTypeBuilder<WorkWeekPolicyDay> builder)
    {
        builder.ToTable("WorkWeekPolicyDay");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.HasIndex(e => new { e.WorkWeekPolicyId, e.DayOfWeek }).IsUnique();

        // WorkWeekPolicy relationship configured from WorkWeekPolicyConfiguration
    }
}

public sealed class WorkWeekPolicyAssignmentConfiguration : IEntityTypeConfiguration<WorkWeekPolicyAssignment>
{
    public void Configure(EntityTypeBuilder<WorkWeekPolicyAssignment> builder)
    {
        builder.ToTable("WorkWeekPolicyAssignment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.HasOne(e => e.WorkWeekPolicy)
            .WithMany()
            .HasForeignKey(e => e.WorkWeekPolicyId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ShiftSwapRequestConfiguration : IEntityTypeConfiguration<ShiftSwapRequest>
{
    public void Configure(EntityTypeBuilder<ShiftSwapRequest> builder)
    {
        builder.ToTable("ShiftSwapRequest");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.ShiftSwapStatus).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Remarks).HasMaxLength(1000);

        // ShiftSwapStatusGroup is a computed/persisted column — EF should not write to it
        builder.Property(e => e.ShiftSwapStatusGroup)
            .HasComputedColumnSql("CAST('SHIFT_SWAP_STATUS' AS NVARCHAR(50))", stored: true);

        builder.HasOne(e => e.RequesterRoster)
            .WithMany()
            .HasForeignKey(e => e.RequesterRosterId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.TargetRoster)
            .WithMany()
            .HasForeignKey(e => e.TargetRosterId)
            .OnDelete(DeleteBehavior.Restrict);

        // RequesterEmployeeId, TargetEmployeeId, WorkflowInstanceId, ApprovedBy: cross-schema — no EF relationship
    }
}

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.ToTable("OutboxMessages", "attendance");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.EventType).HasMaxLength(500).IsRequired();
        builder.Property(e => e.Exchange).HasMaxLength(200).IsRequired();
        builder.Property(e => e.RoutingKey).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Status).HasMaxLength(50).IsRequired();
    }
}

public sealed class RosterGenerationPolicyConfiguration : IEntityTypeConfiguration<RosterGenerationPolicy>
{
    public void Configure(EntityTypeBuilder<RosterGenerationPolicy> builder)
    {
        builder.ToTable("RosterGenerationPolicy");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();
        builder.Property(e => e.PolicyCode).HasMaxLength(100).IsRequired();
        builder.Property(e => e.PolicyName).HasMaxLength(200).IsRequired();
        builder.Property(e => e.GenerationType).HasMaxLength(50).IsRequired();

        // GenerationTypeGroup is a persisted computed column — EF should not write to it
        builder.Property(e => e.GenerationTypeGroup)
            .HasComputedColumnSql("CAST('ROSTER_GENERATION_TYPE' AS NVARCHAR(50))", stored: true);

        builder.HasIndex(e => e.PolicyCode).IsUnique();

        // Intra-schema: one policy has many assignments
        builder.HasMany(e => e.Assignments)
            .WithOne(a => a.RosterGenerationPolicy)
            .HasForeignKey(a => a.RosterGenerationPolicyId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class RosterGenerationPolicyAssignmentConfiguration
    : IEntityTypeConfiguration<RosterGenerationPolicyAssignment>
{
    public void Configure(EntityTypeBuilder<RosterGenerationPolicyAssignment> builder)
    {
        builder.ToTable("RosterGenerationPolicyAssignment");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        // Unique constraint matching UX_RosterGenerationPolicyAssignment_Scope in SQL DDL
        builder.HasIndex(e => new { e.ScopeTypeId, e.ScopeReferenceId, e.EffectiveFrom }).IsUnique();

        // Recommended indexes
        builder.HasIndex(e => e.RosterGenerationPolicyId);
        builder.HasIndex(e => e.ScopeTypeId);
        builder.HasIndex(e => e.ScopeReferenceId);

        // Intra-schema: RosterGenerationPolicyId → RosterGenerationPolicy
        // (relationship configured from RosterGenerationPolicyConfiguration.HasMany)

        // ScopeTypeId: cross-schema FK to time.ScopeType — no EF relationship
    }
}

