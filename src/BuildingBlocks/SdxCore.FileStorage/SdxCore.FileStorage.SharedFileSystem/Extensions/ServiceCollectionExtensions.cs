using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.FileStorage.Abstractions;

namespace SdxCore.FileStorage.SharedFileSystem.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreSharedFileSystem(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<FileStorageOptions>(configuration.GetSection("FileStorage"));
        services.AddScoped<IFileStorageService, SharedFileSystemProvider>();
        return services;
    }
}
