using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Messaging.BackgroundServices;
using SdxCore.Messaging.Extensions;
using SdxCore.Time.Application.Abstractions.Services;
using SdxCore.Time.Application.Consumers;
using SdxCore.Time.Application.Services;
using System.Reflection;

namespace SdxCore.Time.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreTimeApplication(this IServiceCollection services)
    {
        // Register FluentValidation validators
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        // Register Services
        
        services.AddScoped<IBiometricDeviceService, BiometricDeviceService>();
        services.AddScoped<IGeoFenceService, GeoFenceService>();
        services.AddScoped<IDocumentTypeService, DocumentTypeService>();
        services.AddScoped<IDesignationService, DesignationService>();
        services.AddScoped<IScopeTypeService, ScopeTypeService>();
        services.AddScoped<IOfficeLocationService, OfficeLocationService>();
        services.AddScoped<ILegalEntityService, LegalEntityService>();
        services.AddScoped<IRegionService, RegionService>();
        services.AddScoped<ICountryService, CountryService>();
        services.AddScoped<ITimeZoneMasterService, TimeZoneMasterService>();
        services.AddScoped<IDepartmentService, DepartmentService>();

        // Register Background Services
        services.AddHostedService<OutboxProcessorBackgroundService>();

        return services;
    }

    public static IServiceCollection AddSdxCoreTimeMessaging(this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "time";

        services.AddSdxMessaging(
            configuration,
            endpointPrefix: serviceName,
            configureBus =>
            {
                configureBus.AddConsumer<EntityChangedEventConsumer>();
            });

        return services;
    }
}
