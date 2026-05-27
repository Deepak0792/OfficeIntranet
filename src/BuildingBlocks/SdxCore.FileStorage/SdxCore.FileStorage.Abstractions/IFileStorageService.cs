using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.FileStorage.Abstractions;

public interface IFileStorageService
{
    Task<string> UploadAsync(Stream stream, string fileName, string contentType, string module, CancellationToken cancellationToken = default);
    Task<Stream> DownloadAsync(string filePath, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(string filePath, CancellationToken cancellationToken = default);
    Task<string> GetUrlAsync(string filePath, CancellationToken cancellationToken = default);
}
