using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.Employee.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<EmployeeDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                b => b.MigrationsAssembly(typeof(EmployeeDbContext).Assembly.FullName)));

        services.AddScoped<IEmployeeRepository, EmployeeRepository>();
        services.AddScoped<IEmployeeViewRepository, EmployeeViewRepository>();
        services.AddScoped<ISkillRepository, SkillRepository>();
        services.AddScoped<IEmployeeSkillRepository, EmployeeSkillRepository>();
        services.AddScoped<ITeamRepository, TeamRepository>();
        services.AddScoped<IEmployeeTeamRepository, EmployeeTeamRepository>();
        services.AddScoped<IBiometricMappingRepository, BiometricMappingRepository>();
        
        services.AddScoped<IEmployeeLegalEntityRepository, EmployeeLegalEntityRepository>();
        services.AddScoped<IEmployeeDepartmentRepository, EmployeeDepartmentRepository>();
        services.AddScoped<IEmployeeLocationRepository, EmployeeLocationRepository>();
        services.AddScoped<IEmployeeRelationshipRepository, EmployeeRelationshipRepository>();
        services.AddScoped<IEmployeeContactRepository, EmployeeContactRepository>();
        services.AddScoped<IEmployeeDocumentRepository, EmployeeDocumentRepository>();
        services.AddScoped<IEmployeeAddressRepository, EmployeeAddressRepository>();

        return services;
    }
}
