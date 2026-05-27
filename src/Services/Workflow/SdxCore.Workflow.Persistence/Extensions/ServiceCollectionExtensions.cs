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
            return new OutboxRepository(dbContext);
        });

        return services;
    }
}
