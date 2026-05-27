using Microsoft.Extensions.DependencyInjection;
using SdxCore.Employee.Application.Services;

namespace SdxCore.Employee.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddEmployeeServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<EmployeeProfileService>();
        return services;
    }
}
