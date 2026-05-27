using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Outbox;
using SdxCore.Attendance.Persistence.Data;
using System.Text.Json;

namespace SdxCore.Attendance.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAttendancePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<OutboxSaveChangesInterceptor>();
        
        services.AddDbContext<AttendanceDbContext>((sp, options) =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });
        
        services.AddScoped<IOutboxRepository>(sp => 
        {
            var dbContext = sp.GetRequiredService<AttendanceDbContext>();
            return new OutboxRepository(dbContext, JsonSerializerOptions.Default);
        });

        return services;
    }
}
