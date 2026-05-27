$persistenceDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Persistence\Extensions"
$appDir = "d:\Office\SdxCore\src\Services\Workflow\SdxCore.Workflow.Application\Extensions"

New-Item -ItemType Directory -Force -Path $persistenceDir | Out-Null
New-Item -ItemType Directory -Force -Path $appDir | Out-Null

$persistenceExt = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Outbox;
using SdxCore.Workflow.Domain.Interfaces.Repositories;
using SdxCore.Workflow.Persistence.Data;
using SdxCore.Workflow.Persistence.Repositories;
using System.Text.Json;

namespace SdxCore.Workflow.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddWorkflowPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<OutboxSaveChangesInterceptor>();
        
        services.AddDbContext<WorkflowDbContext>((sp, options) =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });

        services.AddScoped(typeof(IBaseRepository<>), typeof(BaseRepository<>));
        
        // Register generic OutboxRepository for WorkflowDbContext
        services.AddScoped<IOutboxRepository>(sp => 
        {
            var dbContext = sp.GetRequiredService<WorkflowDbContext>();
            return new OutboxRepository(dbContext, JsonSerializerOptions.Default);
        });

        return services;
    }
}
"@
Set-Content -Path "$persistenceDir\ServiceCollectionExtensions.cs" -Value $persistenceExt

$appExt = @"
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
"@
Set-Content -Path "$appDir\ServiceCollectionExtensions.cs" -Value $appExt
