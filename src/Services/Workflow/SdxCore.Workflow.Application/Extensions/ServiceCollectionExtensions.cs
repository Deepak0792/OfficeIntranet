using Microsoft.Extensions.DependencyInjection;
using SdxCore.Workflow.Application.BackgroundServices;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.Services;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreWorkflowApplication(this IServiceCollection services)
    {
        services.AddScoped<IWorkflowModuleService, WorkflowModuleService>();
        services.AddScoped<IWorkflowDefinitionService, WorkflowDefinitionService>();
        services.AddScoped<IWorkflowStepService, WorkflowStepService>();
        services.AddScoped<IWorkflowStepApproverService, WorkflowStepApproverService>();
        services.AddScoped<IWorkflowStepApproverDesignationService, WorkflowStepApproverDesignationService>();
        services.AddScoped<IWorkflowAssignmentService, WorkflowAssignmentService>();
        services.AddScoped<IWorkflowInstanceService, WorkflowInstanceService>();
        services.AddScoped<IWorkflowTaskService, WorkflowTaskService>();

        services.AddScoped<IWorkflowEngine, WorkflowEngine>();

        // Register Background Services
        services.AddHostedService<OutboxProcessorBackgroundService>();

        return services;
    }
}
