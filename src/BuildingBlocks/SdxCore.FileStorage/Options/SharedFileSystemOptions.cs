namespace SdxCore.FileStorage.Options;

public class SharedFileSystemOptions
{
    public string RootPath { get; set; } = "/mnt/sdxcore-files";
    public string Environment { get; set; } = "development";
    public string Tenant { get; set; } = "sdxcore";
}
