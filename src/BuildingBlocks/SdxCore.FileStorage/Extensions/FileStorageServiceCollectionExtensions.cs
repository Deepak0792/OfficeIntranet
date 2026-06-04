namespace SdxCore.FileStorage.Extensions;

using System;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.FileStorage.Abstractions;
using SdxCore.FileStorage.Options;
using SdxCore.FileStorage.Providers.SharedFileSystem;

public static class FileStorageServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreFileStorage(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<FileStorageOptions>(configuration.GetSection("FileStorage"));

        var options = configuration.GetSection("FileStorage").Get<FileStorageOptions>() ?? new FileStorageOptions();

        switch (options.ProviderType)
        {
            case ProviderType.SharedFileSystem:
                services.AddScoped<IFileStorageService, SharedFileSystemProvider>();
                break;
            default:
                throw new NotImplementedException($"Provider {options.ProviderType} is not supported yet.");
        }

        return services;
    }
}
