using SdxCore.FileStorage.Models;

namespace SdxCore.File.Application.Abstractions.Services;

/// <summary>
/// Application-level file management service contract.
/// Orchestrates validation and delegates storage operations to IFileStorageService.
/// </summary>
public interface IFileService
{
    /// <summary>Uploads a file and returns the storage result.</summary>
    Task<UploadFileResponse> UploadAsync(UploadFileRequest request, CancellationToken cancellationToken = default);

    /// <summary>Downloads a file by its encrypted path.</summary>
    Task<DownloadFileResponse> DownloadAsync(string encryptedFilePath, CancellationToken cancellationToken = default);
}
