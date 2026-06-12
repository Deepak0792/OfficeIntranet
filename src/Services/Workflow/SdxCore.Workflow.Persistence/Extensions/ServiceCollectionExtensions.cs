using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Interceptors;
using SdxCore.Workflow.Domain.Abstractions;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Persistence.Data;
using SdxCore.Workflow.Persistence.Repositories;

namespace SdxCore.Workflow.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreWorkflowPersistence(
        this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHttpContextAccessor();
        services.AddSingleton<AuditInterceptor>();
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
            options.AddInterceptors(
                sp.GetRequiredService<AuditInterceptor>(),
                sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });

        services.AddScoped<IWorkflowUnitOfWork, WorkflowUnitOfWork>();
        services.AddScoped<IUnitOfWork>(
            sp => sp.GetRequiredService<IWorkflowUnitOfWork>());

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
