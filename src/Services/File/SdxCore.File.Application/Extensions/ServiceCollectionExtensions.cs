using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.File.Application.Abstractions.Services;
using SdxCore.File.Application.Services;
using System.Reflection;

namespace SdxCore.File.Application.Extensions;

/// <summary>
/// Dependency injection extensions for the File Application layer.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers all File Application services and validators.
    /// </summary>
    public static IServiceCollection AddSdxCoreFileApplication(this IServiceCollection services)
    {
        // Auto-discover all FluentValidation validators in this assembly
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        // Register application services
        services.AddScoped<IFileService, FileService>();

        return services;
    }
}
