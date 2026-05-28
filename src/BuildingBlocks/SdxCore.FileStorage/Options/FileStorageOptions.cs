namespace SdxCore.FileStorage.Options;

public class FileStorageOptions
{
    public ProviderType ProviderType { get; set; } = ProviderType.SharedFileSystem;
    public SharedFileSystemOptions SharedFileSystem { get; set; } = new();
}
