namespace SdxCore.FileStorage.Models;

public class DownloadFileResponse : IDisposable
{
    public Stream Stream { get; set; } = null!;
    public string ContentType { get; set; } = string.Empty;
    public string OriginalFileName { get; set; } = string.Empty;

    public void Dispose()
    {
        Stream?.Dispose();
    }
}
