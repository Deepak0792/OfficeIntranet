using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Time.Domain.Interfaces.Repositories;
using SdxCore.Time.Persistence.Data;
using SdxCore.Time.Persistence.Repositories;

namespace SdxCore.Time.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddTimePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<TimeDbContext>(options =>
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

        // Register Repositories
        services.AddScoped<IBiometricDeviceRepository, BiometricDeviceRepository>();
        services.AddScoped<IGeoFenceRepository, GeoFenceRepository>();
        services.AddScoped<IDocumentTypeRepository, DocumentTypeRepository>();
        services.AddScoped<IDesignationRepository, DesignationRepository>();
        services.AddScoped<IScopeTypeRepository, ScopeTypeRepository>();
        services.AddScoped<IOfficeLocationRepository, OfficeLocationRepository>();
        services.AddScoped<ILegalEntityRepository, LegalEntityRepository>();
        services.AddScoped<IRegionRepository, RegionRepository>();
        services.AddScoped<ICountryRepository, CountryRepository>();
        services.AddScoped<ITimeZoneMasterRepository, TimeZoneMasterRepository>();
        services.AddScoped<IDepartmentRepository, DepartmentRepository>();

        return services;
    }
}
