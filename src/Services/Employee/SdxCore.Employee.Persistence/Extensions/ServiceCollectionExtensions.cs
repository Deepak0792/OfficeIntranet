using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Domain;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.Employee.Persistence.Repositories;
using SdxCore.SharedKernel.Persistence;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Employee.Persistence.Extensions;
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreEmployeePersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddHttpContextAccessor();
        services.AddSingleton<AuditInterceptor>();
        services.AddSingleton<OutboxSaveChangesInterceptor>();

        services.AddDbContext<EmployeeDbContext>((sp, options) =>
        {
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sql => sql.EnableRetryOnFailure(3, TimeSpan.FromSeconds(10), null));

            options.AddInterceptors(
                sp.GetRequiredService<AuditInterceptor>(),
                sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });

        services.AddScoped<IEmployeeUnitOfWork, EmployeeUnitOfWork>();
        services.AddScoped<IUnitOfWork>(
            sp => sp.GetRequiredService<IEmployeeUnitOfWork>());

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