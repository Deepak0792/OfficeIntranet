using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Application.Abstractions.Services;
using SdxCore.Employee.Application.Consumers;
using SdxCore.Employee.Application.Services;
using SdxCore.Messaging.BackgroundServices;
using SdxCore.Messaging.Extensions;
using System.Reflection;

namespace SdxCore.Employee.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreEmployeeApplication(this IServiceCollection services)
    {
        // Register all FluentValidation validators in this assembly via auto-discovery
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<ISkillService, SkillService>();
        services.AddScoped<ITeamService, TeamService>();
        services.AddScoped<IEmployeeSkillService, EmployeeSkillService>();
        services.AddScoped<IEmployeeTeamService, EmployeeTeamService>();
        services.AddScoped<IEmployeeBiometricMappingService, EmployeeBiometricMappingService>();

        // Phase 3 Services
        services.AddScoped<IEmployeeLegalEntityService, EmployeeLegalEntityService>();
        services.AddScoped<IEmployeeDepartmentService, EmployeeDepartmentService>();
        services.AddScoped<IEmployeeLocationService, EmployeeLocationService>();
        services.AddScoped<IEmployeeRelationshipService, EmployeeRelationshipService>();
        services.AddScoped<IEmployeeContactService, EmployeeContactService>();
        services.AddScoped<IEmployeeDocumentService, EmployeeDocumentService>();
        services.AddScoped<IEmployeeAddressService, EmployeeAddressService>();

        // Register Background Services
        services.AddHostedService<OutboxProcessorBackgroundService>();

        return services;
    }

    public static IServiceCollection AddSdxCoreEmployeeMessaging(this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "employee";

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
