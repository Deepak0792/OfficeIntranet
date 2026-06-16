using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Instance.Request;

namespace SdxCore.Workflow.Application.Consumers;

public sealed class ShiftSwapRequestSubmittedConsumer
    : IConsumer<ShiftSwapRequestSubmittedEvent>
{
    private readonly IWorkflowInstanceService _workflowInstanceService;
    private readonly ILogger<ShiftSwapRequestSubmittedConsumer> _logger;

    public ShiftSwapRequestSubmittedConsumer(
        IWorkflowInstanceService workflowInstanceService,
        ILogger<ShiftSwapRequestSubmittedConsumer> logger)
    {
        _workflowInstanceService = workflowInstanceService;
        _logger = logger;
    }

    public async Task Consume(
        ConsumeContext<ShiftSwapRequestSubmittedEvent> context)
    {
        var evt = context.Message;

        _logger.LogInformation(
            "Shift swap request submitted. RequestId={Id}, Requester={RequesterId}, Target={TargetId}",
            evt.ShiftSwapRequestId,
            evt.RequesterEmployeeId,
            evt.TargetEmployeeId);

        try
        {
            var workflowCode = GetWorkflowCode(evt);
            var request = new SubmitWorkflowInstanceRequest(
                ModuleCode: evt.ModuleCode,
                WorkflowCode: workflowCode,
                ReferenceTransactionId: evt.ShiftSwapRequestId,
                InitiatedByEmployeeId: evt.RequesterEmployeeId);

            var instance = await _workflowInstanceService.CreateAsync(
                request,
                context.CancellationToken);

            _logger.LogInformation(
                "Workflow created. InstanceId={InstanceId}, ShiftSwapRequestId={RequestId}",
                instance.Id,
                evt.ShiftSwapRequestId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to initiate workflow for ShiftSwapRequestId={Id}",
                evt.ShiftSwapRequestId);

            throw;
        }
    }

    private static string GetWorkflowCode(ShiftSwapRequestSubmittedEvent evt)
    {
        return "WF_SHIFT_SWAP_REQUEST_V1";
    }
}