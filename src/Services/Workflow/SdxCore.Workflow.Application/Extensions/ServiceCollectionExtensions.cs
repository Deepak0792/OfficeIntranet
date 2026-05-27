using Microsoft.Extensions.DependencyInjection;
using SdxCore.Workflow.Application.Services;
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddWorkflowServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<IWorkflowResolutionService, WorkflowResolutionService>();
        return services;
    }
}
