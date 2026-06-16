using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Instance.Request;

namespace SdxCore.Workflow.Application.Consumers;

public sealed class CompOffRedemptionSubmittedConsumer
    : IConsumer<CompOffRedemptionSubmittedEvent>
{
    private readonly IWorkflowInstanceService _workflowInstanceService;
    private readonly ILogger<CompOffRedemptionSubmittedConsumer> _logger;

    public CompOffRedemptionSubmittedConsumer(
        IWorkflowInstanceService workflowInstanceService,
        ILogger<CompOffRedemptionSubmittedConsumer> logger)
    {
        _workflowInstanceService = workflowInstanceService;
        _logger = logger;
    }

    public async Task Consume(
        ConsumeContext<CompOffRedemptionSubmittedEvent> context)
    {
        var evt = context.Message;

        _logger.LogInformation(
            "CompOff redemption submitted. CompOffBalanceId={Id}, EmployeeId={EmployeeId}",
            evt.CompOffBalanceId,
            evt.EmployeeId);

        try
        {
            var workflowCode = GetWorkflowCode(evt);

            var request = new SubmitWorkflowInstanceRequest(
                ModuleCode: evt.ModuleCode,
                WorkflowCode: workflowCode,
                ReferenceTransactionId: evt.CompOffBalanceId,
                InitiatedByEmployeeId: evt.EmployeeId);

            var instance = await _workflowInstanceService.CreateAsync(
                request,
                context.CancellationToken);

            _logger.LogInformation(
                "Workflow created. InstanceId={InstanceId}, CompOffBalanceId={CompOffBalanceId}",
                instance.Id,
                evt.CompOffBalanceId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to initiate workflow for CompOffBalanceId={Id}",
                evt.CompOffBalanceId);

            throw;
        }
    }

    private static string GetWorkflowCode(CompOffRedemptionSubmittedEvent evt)
    {
        return "WF_COMP_OFF_REQUEST_V1";
    }
}