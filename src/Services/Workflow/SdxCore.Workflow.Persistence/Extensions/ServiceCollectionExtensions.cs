using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.SharedKernel.Persistence;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;
using SdxCore.Workflow.Persistence.Repositories;

namespace SdxCore.Workflow.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreWorkflowPersistence(
        this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSingleton<OutboxSaveChangesInterceptor>();

        services.AddDbContext<WorkflowDbContext>((sp, options) =>
        {
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sqlOptions =>
                {
                    sqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 3,
                        maxRetryDelay: TimeSpan.FromSeconds(10),
                        errorNumbersToAdd: null);
                });
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });

        services.AddScoped<IWorkflowActionHistoryRepository, WorkflowActionHistoryRepository>();
        services.AddScoped<IWorkflowAssignmentRepository, WorkflowAssignmentRepository>();
        services.AddScoped<IWorkflowDefinitionRepository, WorkflowDefinitionRepository>();
        services.AddScoped<IWorkflowInstanceRepository, WorkflowInstanceRepository>();
        services.AddScoped<IWorkflowModuleRepository, WorkflowModuleRepository>();
        services.AddScoped<IWorkflowStepApproverDesignationRepository, WorkflowStepApproverDesignationRepository>();
        services.AddScoped<IWorkflowStepApproverRepository, WorkflowStepApproverRepository>();
        services.AddScoped<IWorkflowStepRepository, WorkflowStepRepository>();
        services.AddScoped<IWorkflowTaskRepository, WorkflowTaskRepository>();
        services.AddScoped<IOutboxRepository, OutboxRepository>();
        services.AddScoped<IWorkflowOutboxPublisher, WorkflowOutboxPublisher>();

        return services;
    }
}
