using Microsoft.Extensions.DependencyInjection;
using SdxCore.Shared.Application.Services;
using SdxCore.Shared.Application.Abstractions.Services;

namespace SdxCore.Shared.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreSharedApplication(this IServiceCollection services)
    {
        services.AddScoped<ILookupService, LookupService>();

        return services;
    }
}
