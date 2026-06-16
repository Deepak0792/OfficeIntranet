using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;
using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Events;
using System.Text.Json;

namespace SdxCore.Attendance.Persistence.Interceptors;

/// <summary>
/// Watches newly Added workflow-triggering entities and writes typed outbox events.
/// Does NOT call SaveChangesAsync — the caller (service) owns the single commit.
/// </summary>
public sealed class AttendanceWorkflowOutboxInterceptor : SaveChangesInterceptor
{
    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        if (eventData.Context is null)
            return base.SavingChangesAsync(eventData, result, cancellationToken);

        var context = eventData.Context;

        foreach (var entry in context.ChangeTracker.Entries().ToList())
        {
            if (entry.State != EntityState.Added) continue;

            OutboxMessage? outbox = entry.Entity switch
            {
                LeaveRequest lr when lr.WorkflowInstanceId is null => BuildLeaveOutbox(lr),
                AttendanceRegularization ar when ar.WorkflowInstanceId is null => BuildRegularizationOutbox(ar),
                ShiftSwapRequest ssr when ssr.WorkflowInstanceId is null => BuildShiftSwapOutbox(ssr),
                CompOffBalance cob when cob.WorkflowInstanceId is null => BuildCompOffOutbox(cob),
                _ => null
            };

            if (outbox is not null)
                context.Set<OutboxMessage>().Add(outbox);
        }

        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    private static OutboxMessage BuildLeaveOutbox(LeaveRequest lr) => new()
    {
        Id = Guid.NewGuid(),
        EventType = typeof(LeaveRequestSubmittedEvent).AssemblyQualifiedName!,
        Exchange = "sdxcore.attendance",
        RoutingKey = "sdxcore.leave.submitted",
        Payload = JsonSerializer.Serialize(new LeaveRequestSubmittedEvent(
        LeaveRequestId: lr.Id,
        EmployeeId: lr.EmployeeId,
        LeaveTypeCode: GetLeaveTypeCode(lr),
        ModuleCode: WorkflowModuleCodes.Leave,
        FromDate: lr.FromDate,
        ToDate: lr.ToDate,
        Remarks: lr.Reason,
        CreatedAt: DateTime.UtcNow)),
        Status = OutboxStatus.Pending,
        StatusGroup = "OUTBOX_STATUS",

        IsActive = true,
        RetryCount = 0,
        CreatedAt = DateTime.UtcNow,
        CreatedBy = SystemUser.SystemUserId,
        LastUpdatedAt = DateTime.UtcNow,
        LastUpdatedBy = SystemUser.SystemUserId
    };

    private static OutboxMessage BuildRegularizationOutbox(AttendanceRegularization ar) => new()
    {
        Id = Guid.NewGuid(),
        EventType = typeof(AttendanceRegularizationSubmittedEvent).AssemblyQualifiedName!,
        Exchange = "sdxcore.attendance",
        RoutingKey = "sdxcore.regularization.submitted",
        Payload = JsonSerializer.Serialize(new AttendanceRegularizationSubmittedEvent(
            RegularizationId: ar.Id,
            EmployeeId: ar.EmployeeId,
            ModuleCode: WorkflowModuleCodes.AttendanceRegularization,
            AttendanceDate: ar.AttendanceDate,
            RequestedCheckIn: ar.RequestedCheckIn,
            RequestedCheckOut: ar.RequestedCheckOut,
            Reason: ar.Reason,
            CreatedAt: DateTime.UtcNow
        )),
        Status = OutboxStatus.Pending,
        StatusGroup = "OUTBOX_STATUS",

        IsActive = true,
        RetryCount = 0,
        CreatedAt = DateTime.UtcNow,
        CreatedBy = SystemUser.SystemUserId,
        LastUpdatedAt = DateTime.UtcNow,
        LastUpdatedBy = SystemUser.SystemUserId
    };

    private static OutboxMessage BuildShiftSwapOutbox(ShiftSwapRequest ssr) => new()
    {
        Id = Guid.NewGuid(),
        EventType = typeof(ShiftSwapRequestSubmittedEvent).AssemblyQualifiedName!,
        Exchange = "sdxcore.attendance",
        RoutingKey = "sdxcore.shiftswap.submitted",
        Payload = JsonSerializer.Serialize(new ShiftSwapRequestSubmittedEvent(
            ShiftSwapRequestId: ssr.Id,
            RequesterEmployeeId: ssr.RequesterEmployeeId,
            TargetEmployeeId: ssr.TargetEmployeeId,
            RequesterRosterId: ssr.RequesterRosterId,
            TargetRosterId: ssr.TargetRosterId,
            ModuleCode: WorkflowModuleCodes.ShiftSwap,
            CreatedAt: DateTime.UtcNow
        )),
        Status = OutboxStatus.Pending,
        CreatedAt = DateTime.UtcNow
    };


    private static OutboxMessage BuildCompOffOutbox(CompOffBalance cob) => new()
    {
        Id = Guid.NewGuid(),
        EventType = typeof(CompOffRedemptionSubmittedEvent).AssemblyQualifiedName!,
        Exchange = "sdxcore.attendance",
        RoutingKey = "sdxcore.compoff.submitted",
        Payload = JsonSerializer.Serialize(new CompOffRedemptionSubmittedEvent(
            CompOffBalanceId: cob.Id,
            EmployeeId: cob.EmployeeId,
            ModuleCode: WorkflowModuleCodes.CompOff,
            TotalDays: cob.TotalDays,
            CreatedAt: DateTime.UtcNow
        )),
        Status = OutboxStatus.Pending,
        StatusGroup = "OUTBOX_STATUS",

        IsActive = true,
        RetryCount = 0,
        CreatedAt = DateTime.UtcNow,
        CreatedBy = SystemUser.SystemUserId,
        LastUpdatedAt = DateTime.UtcNow,
        LastUpdatedBy = SystemUser.SystemUserId
    };

    private static string GetLeaveTypeCode(LeaveRequest lr)
    {
        return lr.LeaveType?.LeaveCode
            ?? throw new InvalidOperationException(
                $"LeaveCode is not available for LeaveRequest {lr.Id}. " +
                "Ensure LeaveType navigation is loaded before SaveChanges.");
    }
}
