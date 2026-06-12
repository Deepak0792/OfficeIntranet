namespace SdxCore.FileStorage.Providers.SharedFileSystem;

using Microsoft.Extensions.Options;
using SdxCore.Common.Security.Cryptography;
using SdxCore.FileStorage.Abstractions;
using SdxCore.FileStorage.Models;
using SdxCore.FileStorage.Options;
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

public class SharedFileSystemProvider : IFileStorageService
{
    private readonly SharedFileSystemOptions _options;

    public SharedFileSystemProvider(IOptions<FileStorageOptions> options)
    {
        _options = options.Value.SharedFileSystem;
    }

    public async Task<UploadFileResponse> UploadAsync(UploadFileRequest request, CancellationToken cancellationToken = default)
    {
        var year = DateTime.UtcNow.Year.ToString();
        var month = DateTime.UtcNow.Month.ToString("D2");
        var guid = Guid.NewGuid().ToString("N");
        var originalFileName = request.FileName;
        var safeFileName = $"{guid}_{originalFileName}";

        var relativePath = Path.Combine(
            _options.Environment,
            _options.Tenant,
            request.Microservice,
            year,
            month,
            request.FileType,
            safeFileName).Replace("\\", "/");

        var absolutePath = Path.Combine(_options.RootPath, relativePath);
        var directory = Path.GetDirectoryName(absolutePath);

        if (!Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory!);
        }

        using var fileStream = new FileStream(absolutePath, FileMode.Create, FileAccess.Write, FileShare.None, 4096, true);
        await request.Stream.CopyToAsync(fileStream, cancellationToken);

        return new UploadFileResponse
        {
            FileUrl = $"/{PasswordHasher.Encrypt(relativePath)}",
            FileName = safeFileName,
            FileSizeInBytes = fileStream.Length,
            ContentType = request.ContentType
        };
    }

    public Task<DownloadFileResponse> DownloadAsync(string encryptedFilePath, CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(encryptedFilePath, "Encrypted file path cannot be null or empty.");

        var filePath = PasswordHasher.Decrypt(encryptedFilePath);

        ArgumentException.ThrowIfNullOrWhiteSpace(filePath, "Decrypted file path cannot be null or empty.");

        if (filePath.StartsWith("/"))
        {
            filePath = filePath.Substring(1);
        }

        var absolutePath = Path.Combine(_options.RootPath, filePath);

        if (!File.Exists(absolutePath))
        {
            throw new FileNotFoundException($"File not found at {absolutePath}");
        }

        var stream = new FileStream(absolutePath, FileMode.Open, FileAccess.Read, FileShare.Read, 4096, true);

        return Task.FromResult(new DownloadFileResponse
        {
            Stream = stream,
            OriginalFileName = Path.GetFileName(absolutePath),
            ContentType = "application/octet-stream"
        });
    }

    public Task<bool> DeleteAsync(string filePath, CancellationToken cancellationToken = default)
    {
        if (filePath.StartsWith("/"))
        {
            filePath = filePath.Substring(1);
        }

        var absolutePath = Path.Combine(_options.RootPath, filePath);

        if (File.Exists(absolutePath))
        {
            File.Delete(absolutePath);
            return Task.FromResult(true);
        }

        return Task.FromResult(false);
    }

    public Task<bool> ExistsAsync(string filePath, CancellationToken cancellationToken = default)
    {
        if (filePath.StartsWith("/"))
        {
            filePath = filePath.Substring(1);
        }

        var absolutePath = Path.Combine(_options.RootPath, filePath);
        return Task.FromResult(File.Exists(absolutePath));
    }
}
