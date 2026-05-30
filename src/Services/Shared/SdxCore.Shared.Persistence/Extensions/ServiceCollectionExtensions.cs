using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Shared.Domain.Interfaces.Repositories;
using SdxCore.Shared.Persistence.Data;
using SdxCore.Shared.Persistence.Repositories;

namespace SdxCore.Shared.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSharedPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<SharedDbContext>(options =>
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
        });

        services.AddScoped<ILookupRepository, LookupRepository>();

        return services;
    }
}
