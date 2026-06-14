using Microsoft.Extensions.Logging;
using SdxCore.File.Application.Abstractions.Services;
using SdxCore.FileStorage.Abstractions;
using SdxCore.FileStorage.Models;

namespace SdxCore.File.Application.Services;

/// <summary>
/// Orchestrates file operations: maps Application DTOs to storage-layer models and delegates to IFileStorageService.
/// </summary>
public class FileService(IFileStorageService storageService, ILogger<FileService> logger) : IFileService
{
    private readonly IFileStorageService _storageService = storageService;
    private readonly ILogger<FileService> _logger = logger;

    public async Task<UploadFileResponse> UploadAsync(UploadFileRequest request, CancellationToken cancellationToken = default)
    {
        var result = await _storageService.UploadAsync(request, cancellationToken);

        _logger.LogInformation("File uploaded: {FileName} ({Size} bytes) by {Microservice}",
            result.FileName, result.FileSizeInBytes, request.Microservice);
        return result;
    }

    /// <inheritdoc />
    public Task<DownloadFileResponse> DownloadAsync(string encryptedFilePath, CancellationToken cancellationToken = default)
    {
        return _storageService.DownloadAsync(encryptedFilePath, cancellationToken);
    }
}
