using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Request;

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
            "LeaveRequest submitted. LeaveRequestId={Id}, Employee={EmployeeId}, WorkflowCode={Code}",
            evt.LeaveRequestId, evt.EmployeeId, evt.WorkflowCode);

        try
        {
            var request = new SubmitWorkflowInstanceRequest(
                ModuleCode: evt.ModuleCode,    // "LEAVE_REQUEST"
                WorkflowCode: evt.WorkflowCode,  // "STANDARD_LEAVE_V1"
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
}