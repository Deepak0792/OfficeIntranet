namespace SdxCore.FileStorage.Abstractions;

public class FileStorageOptions
{
    public string Provider { get; set; } = "SharedFileSystem";
    public SharedFileSystemOptions SharedFileSystem { get; set; } = new();
}

public class SharedFileSystemOptions
{
    public string BasePath { get; set; } = "/mnt/sdxcore-files";
    public string BaseUrl { get; set; } = "http://localhost:5008/files";
}
