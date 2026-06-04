using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.Employee.Persistence.Repositories;
using SdxCore.SharedKernel.Persistence;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Employee.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreEmployeePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSingleton<OutboxSaveChangesInterceptor>();

        services.AddDbContext<EmployeeDbContext>((sp, options) =>
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
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });

        services.AddScoped<IEmployeeRepository, EmployeeRepository>();
        services.AddScoped<IEmployeeViewRepository, EmployeeViewRepository>();
        services.AddScoped<ISkillRepository, SkillRepository>();
        services.AddScoped<IEmployeeSkillRepository, EmployeeSkillRepository>();
        services.AddScoped<ITeamRepository, TeamRepository>();
        services.AddScoped<IEmployeeTeamRepository, EmployeeTeamRepository>();
        services.AddScoped<IEmployeeBiometricMappingRepository, EmployeeBiometricMappingRepository>();
        
        services.AddScoped<IEmployeeLegalEntityRepository, EmployeeLegalEntityRepository>();
        services.AddScoped<IEmployeeDepartmentRepository, EmployeeDepartmentRepository>();
        services.AddScoped<IEmployeeLocationRepository, EmployeeLocationRepository>();
        services.AddScoped<IEmployeeRelationshipRepository, EmployeeRelationshipRepository>();
        services.AddScoped<IEmployeeContactRepository, EmployeeContactRepository>();
        services.AddScoped<IEmployeeDocumentRepository, EmployeeDocumentRepository>();
        services.AddScoped<IEmployeeAddressRepository, EmployeeAddressRepository>();
        services.AddScoped<IOutboxRepository, OutboxRepository>();

        return services;
    }
}
