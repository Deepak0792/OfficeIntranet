using FluentValidation;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Middleware;
using SdxCore.Common.Validators;

namespace SdxCore.Common.Extensions;

/// <summary>
/// Extension methods for registering Common module services with dependency injection.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers SdxCore common infrastructure services.
    /// Installs the centralized <see cref="ValidationLanguageManager"/> globally so that
    /// all FluentValidation validators across every microservice use consistent error messages
    /// without any per-service configuration.
    /// </summary>
    public static IServiceCollection AddSdxCoreCommon(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        // Install centralized validation messages once — applies to all validators project-wide
        ValidatorOptions.Global.LanguageManager = new ValidationLanguageManager();

        return services;
    }
}
