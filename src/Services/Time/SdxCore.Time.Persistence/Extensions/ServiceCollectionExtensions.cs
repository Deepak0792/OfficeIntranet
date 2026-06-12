using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Interceptors;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Persistence.Data;
using SdxCore.Time.Persistence.Repositories;

namespace SdxCore.Time.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreTimePersistence(
        this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHttpContextAccessor();
        services.AddSingleton<AuditInterceptor>();
        services.AddSingleton<OutboxSaveChangesInterceptor>();

        services.AddDbContext<TimeDbContext>((sp, options) =>
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
            options.AddInterceptors(
                sp.GetRequiredService<AuditInterceptor>(),
                sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });
        services.AddScoped<ITimeUnitOfWork, TimeUnitOfWork>();
        services.AddScoped<IUnitOfWork>(
            sp => sp.GetRequiredService<ITimeUnitOfWork>());

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
        services.AddScoped<IOutboxRepository, OutboxRepository>();

        return services;
    }
}
