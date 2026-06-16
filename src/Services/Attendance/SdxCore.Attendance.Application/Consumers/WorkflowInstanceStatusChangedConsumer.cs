using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Common.Enums.Attendance;
using SdxCore.SharedKernel.Events;

namespace SdxCore.Attendance.Application.Consumers;

/// <summary>
/// Consumes WorkflowInstanceStatusChangedEvent from the Workflow service.
/// Routes to the correct attendance application service based on ModuleCode.
/// Must be idempotent and always re-throw exceptions.
/// </summary>
public sealed class WorkflowInstanceStatusChangedConsumer(
    ILeaveService leaveService,
    IAttendanceService attendanceService,
    IShiftSwapService shiftSwapService,
    ICompOffService compOffService,
    ILogger<WorkflowInstanceStatusChangedConsumer> logger)
    : IConsumer<WorkflowInstanceStatusChangedEvent>
{
    public async Task Consume(ConsumeContext<WorkflowInstanceStatusChangedEvent> context)
    {
        var evt = context.Message;

        logger.LogInformation(
            "WorkflowInstanceStatusChanged received. Module={Module}, InstanceId={InstanceId}, Status={Status}",
            evt.ModuleCode, evt.WorkflowInstanceId, evt.NewStatus);

        try
        {
            switch (evt.ModuleCode)
            {
                case WorkflowModuleCodes.Leave:
                    await leaveService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, evt.Remarks, context.CancellationToken);
                    break;

                case WorkflowModuleCodes.AttendanceRegularization:
                    await attendanceService.UpdateRegularizationStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, evt.Remarks, context.CancellationToken);
                    break;

                case WorkflowModuleCodes.ShiftSwap:
                    await shiftSwapService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, evt.Remarks, context.CancellationToken);
                    break;

                case WorkflowModuleCodes.CompOff:
                    await compOffService.UpdateStatusFromWorkflowAsync(
                        evt.WorkflowInstanceId, evt.NewStatus, evt.ActionBy, evt.Remarks, context.CancellationToken);
                    break;

                default:
                    logger.LogWarning("Unrecognised ModuleCode={Module} — skipping.", evt.ModuleCode);
                    break;
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex,
                "Failed to process WorkflowInstanceStatusChangedEvent. Module={Module}, InstanceId={InstanceId}",
                evt.ModuleCode, evt.WorkflowInstanceId);
            throw; // Re-throw → MassTransit retry/fault pipeline
        }
    }
}
