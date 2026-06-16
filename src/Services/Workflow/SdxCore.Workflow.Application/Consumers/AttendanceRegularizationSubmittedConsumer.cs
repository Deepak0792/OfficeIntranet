using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.SharedKernel.Events;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Instance.Request;

namespace SdxCore.Workflow.Application.Consumers;

public sealed class AttendanceRegularizationSubmittedConsumer
    : IConsumer<AttendanceRegularizationSubmittedEvent>
{
    private readonly IWorkflowInstanceService _workflowInstanceService;
    private readonly ILogger<AttendanceRegularizationSubmittedConsumer> _logger;

    public AttendanceRegularizationSubmittedConsumer(
        IWorkflowInstanceService workflowInstanceService,
        ILogger<AttendanceRegularizationSubmittedConsumer> logger)
    {
        _workflowInstanceService = workflowInstanceService;
        _logger = logger;
    }

    public async Task Consume(
        ConsumeContext<AttendanceRegularizationSubmittedEvent> context)
    {
        var evt = context.Message;

        _logger.LogInformation(
            "Attendance regularization submitted. Id={Id}, EmployeeId={EmployeeId}",
            evt.RegularizationId,
            evt.EmployeeId);

        try
        {
            var workflowCode = GetWorkflowCode(evt);
            var request = new SubmitWorkflowInstanceRequest(
                ModuleCode: evt.ModuleCode,
                WorkflowCode: workflowCode,
                ReferenceTransactionId: evt.RegularizationId,
                InitiatedByEmployeeId: evt.EmployeeId);

            var instance = await _workflowInstanceService.CreateAsync(
                request,
                context.CancellationToken);

            _logger.LogInformation(
                "Workflow created. InstanceId={InstanceId}, RegularizationId={RegularizationId}",
                instance.Id,
                evt.RegularizationId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to initiate workflow for RegularizationId={Id}",
                evt.RegularizationId);

            throw;
        }
    }

    private static string GetWorkflowCode(AttendanceRegularizationSubmittedEvent evt)
    {
        return "WF_ATTENDANCE_REG_STD_V1";
    }
}