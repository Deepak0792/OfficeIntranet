using Microsoft.Extensions.DependencyInjection;
using SdxCore.Shared.Application.Services;
using SdxCore.Shared.Domain.Interfaces.Services;

namespace SdxCore.Shared.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSharedApplication(this IServiceCollection services)
    {
        services.AddScoped<ILookupService, LookupService>();

        return services;
    }
}
