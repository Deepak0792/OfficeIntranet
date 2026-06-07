using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using SdxCore.Common.Http;
using SdxCore.Common.Options;
using SdxCore.Messaging.BackgroundServices;
using SdxCore.Messaging.Extensions;
using SdxCore.SharedKernel.Http;
using SdxCore.Workflow.Application.Clients;
using SdxCore.Workflow.Application.Consumers;
using SdxCore.Workflow.Application.Contracts.Clients;
using SdxCore.Workflow.Application.Contracts.Engine;
using SdxCore.Workflow.Application.Contracts.Resolver;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.Engine;
using SdxCore.Workflow.Application.Resolver;
using SdxCore.Workflow.Application.Services;

namespace SdxCore.Workflow.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreWorkflowApplication(this IServiceCollection services)
    {
        services.AddScoped<IWorkflowApproverResolver, WorkflowApproverResolver>();
        services.AddScoped<IWorkflowModuleService, WorkflowModuleService>();
        services.AddScoped<IWorkflowDefinitionService, WorkflowDefinitionService>();
        services.AddScoped<IWorkflowStepService, WorkflowStepService>();
        services.AddScoped<IWorkflowStepApproverService, WorkflowStepApproverService>();
        services.AddScoped<IWorkflowStepApproverDesignationService, WorkflowStepApproverDesignationService>();
        services.AddScoped<IWorkflowAssignmentService, WorkflowAssignmentService>();
        services.AddScoped<IWorkflowInstanceService, WorkflowInstanceService>();
        services.AddScoped<IWorkflowTaskService, WorkflowTaskService>();

        services.AddScoped<IWorkflowEngine, WorkflowEngine>();

        // Internal Handler
        services.AddTransient<InternalApiKeyHandler>();

        services.AddHttpClient<IEmployeeClient, EmployeeClient>((sp, client) =>
        {
            var options = sp.GetRequiredService<IOptions<ClientOptions>>().Value;
            HttpClientConfigurator.Configure(client, options);
        })
        .AddHttpMessageHandler<InternalApiKeyHandler>();

        services.AddHttpClient<ITimeClient, TimeClient>((sp, client) =>
        {
            var options = sp.GetRequiredService<IOptions<ClientOptions>>().Value;
            HttpClientConfigurator.Configure(client, options);
        })
        .AddHttpMessageHandler<InternalApiKeyHandler>();

        // Register Background Services
        services.AddHostedService<OutboxProcessorBackgroundService>();

        return services;
    }

    public static IServiceCollection AddSdxCoreWorkflowMessaging(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "workflow";

        services.AddSdxMessaging(
            configuration,
            endpointPrefix: serviceName,
            configureBus =>
            {
                configureBus.AddConsumer<LeaveRequestSubmittedConsumer>();
            });

        return services;
    }
}
