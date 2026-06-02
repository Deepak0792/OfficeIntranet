using Microsoft.Extensions.DependencyInjection;
using SdxCore.Time.Application.BackgroundServices;
using SdxCore.Time.Application.Interfaces.Services;
using SdxCore.Time.Application.Services;

namespace SdxCore.Time.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddTimeServicesApplication(this IServiceCollection services)
    {
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
        //builder.Services.AddHostedService<CacheInvalidationBackgroundService>();

        return services;
    }
}
