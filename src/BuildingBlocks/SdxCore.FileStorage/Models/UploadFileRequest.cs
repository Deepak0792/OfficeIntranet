namespace SdxCore.FileStorage.Models;

public class UploadFileRequest
{
    public Stream Stream { get; set; } = null!;
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public string Microservice { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
}
