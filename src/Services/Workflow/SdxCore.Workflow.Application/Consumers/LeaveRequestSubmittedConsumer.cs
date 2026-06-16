using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Instance.Request;

namespace SdxCore.Workflow.Application.Consumers;

/// <summary>
/// Consumes LeaveRequestSubmittedEvent from Attendance.
/// Resolves the correct workflow definition and initiates a WorkflowInstance.
/// </summary>
public sealed class LeaveRequestSubmittedConsumer : IConsumer<LeaveRequestSubmittedEvent>
{
    private readonly IWorkflowInstanceService _workflowInstanceService;
    private readonly ILogger<LeaveRequestSubmittedConsumer> _logger;

    public LeaveRequestSubmittedConsumer(
        IWorkflowInstanceService workflowInstanceService,
        ILogger<LeaveRequestSubmittedConsumer> logger)
    {
        _workflowInstanceService = workflowInstanceService;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<LeaveRequestSubmittedEvent> context)
    {
        var evt = context.Message;

        _logger.LogInformation(
            "LeaveRequest submitted. LeaveRequestId={Id}, Employee={EmployeeId}, ModuleCode={Code} {}",
            evt.LeaveRequestId, evt.EmployeeId, evt.ModuleCode, evt.LeaveTypeCode);

        try
        {
            var workflowCode = GetWorkflowCode(evt);

            var request = new SubmitWorkflowInstanceRequest(
                ModuleCode: evt.ModuleCode,
                WorkflowCode: workflowCode,
                ReferenceTransactionId: evt.LeaveRequestId,
                InitiatedByEmployeeId: evt.EmployeeId);

            var instance = await _workflowInstanceService.CreateAsync(
                request, context.CancellationToken);

            _logger.LogInformation(
                "WorkflowInstance created. InstanceId={InstanceId}, LeaveRequestId={LeaveRequestId}",
                instance.Id, evt.LeaveRequestId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Failed to initiate workflow for LeaveRequestId={Id}.", evt.LeaveRequestId);

            // Re-throw → MassTransit retry/fault pipeline handles it
            throw;
        }
    }

    private static string GetWorkflowCode(LeaveRequestSubmittedEvent evt)
    {
        return evt.LeaveTypeCode?.ToUpperInvariant() switch
        {
            "SL" => "WF_LEAVE_EMRGENCY_V1",

            "STUDYLEAVE" => "WF_TRAINING_LEAVE_V1",

            "CL" or
            "EL" or
            "ML" or
            "PL" or
            "OL" or
            "LWP" or
            "COMPOFF" or
            "BL" => "WF_LEAVE_STD_V1",

            _ => "WF_LEAVE_STD_V1"
        };
    }
}