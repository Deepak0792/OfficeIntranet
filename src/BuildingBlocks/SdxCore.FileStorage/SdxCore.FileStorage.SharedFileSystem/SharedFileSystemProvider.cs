using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using SdxCore.FileStorage.Abstractions;

namespace SdxCore.FileStorage.SharedFileSystem;

public class SharedFileSystemProvider : IFileStorageService
{
    private readonly FileStorageOptions _options;

    public SharedFileSystemProvider(IOptions<FileStorageOptions> options)
    {
        _options = options.Value;
        
        if (string.IsNullOrEmpty(_options.SharedFileSystem.BasePath))
        {
            throw new ArgumentException("BasePath is required for SharedFileSystemProvider.");
        }
        
        if (!Directory.Exists(_options.SharedFileSystem.BasePath))
        {
            Directory.CreateDirectory(_options.SharedFileSystem.BasePath);
        }
    }

    public async Task<string> UploadAsync(Stream stream, string fileName, string contentType, string module, CancellationToken cancellationToken = default)
    {
        var moduleDir = Path.Combine(_options.SharedFileSystem.BasePath, module);
        if (!Directory.Exists(moduleDir))
        {
            Directory.CreateDirectory(moduleDir);
        }

        var uniqueFileName = $"{Guid.NewGuid()}_{fileName}";
        var relativePath = Path.Combine(module, uniqueFileName).Replace("\\", "/");
        var absolutePath = Path.Combine(_options.SharedFileSystem.BasePath, relativePath);

        using var fileStream = new FileStream(absolutePath, FileMode.Create, FileAccess.Write, FileShare.None, 4096, true);
        await stream.CopyToAsync(fileStream, cancellationToken);

        return relativePath;
    }

    public Task<Stream> DownloadAsync(string filePath, CancellationToken cancellationToken = default)
    {
        var absolutePath = Path.Combine(_options.SharedFileSystem.BasePath, filePath);
        if (!File.Exists(absolutePath))
        {
            throw new FileNotFoundException($"File not found: {filePath}");
        }

        Stream fileStream = new FileStream(absolutePath, FileMode.Open, FileAccess.Read, FileShare.Read, 4096, true);
        return Task.FromResult(fileStream);
    }

    public Task<bool> DeleteAsync(string filePath, CancellationToken cancellationToken = default)
    {
        var absolutePath = Path.Combine(_options.SharedFileSystem.BasePath, filePath);
        if (File.Exists(absolutePath))
        {
            File.Delete(absolutePath);
            return Task.FromResult(true);
        }
        return Task.FromResult(false);
    }

    public Task<string> GetUrlAsync(string filePath, CancellationToken cancellationToken = default)
    {
        var url = $"{_options.SharedFileSystem.BaseUrl.TrimEnd('/')}/{filePath}";
        return Task.FromResult(url);
    }
}
