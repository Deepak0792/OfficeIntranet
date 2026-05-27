using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Outbox;
using SdxCore.Employee.Persistence.Data;
using System.Text.Json;

namespace SdxCore.Employee.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<OutboxSaveChangesInterceptor>();
        
        services.AddDbContext<EmployeeDbContext>((sp, options) =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });
        
        services.AddScoped<IOutboxRepository>(sp => 
        {
            var dbContext = sp.GetRequiredService<EmployeeDbContext>();
            return new OutboxRepository(dbContext, JsonSerializerOptions.Default);
        });

        return services;
    }
}
