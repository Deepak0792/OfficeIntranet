namespace SdxCore.FileStorage.Abstractions;

using SdxCore.FileStorage.Models;

public interface IFileStorageService
{
    Task<UploadFileResponse> UploadAsync(UploadFileRequest request, CancellationToken cancellationToken = default);
    Task<DownloadFileResponse> DownloadAsync(string filePath, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(string filePath, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(string filePath, CancellationToken cancellationToken = default);
}
