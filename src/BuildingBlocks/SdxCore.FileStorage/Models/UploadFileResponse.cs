namespace SdxCore.FileStorage.Models;

public class UploadFileResponse
{
    public string FileUrl { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public long FileSizeInBytes { get; set; }
    public string ContentType { get; set; } = string.Empty;
}
