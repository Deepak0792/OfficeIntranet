namespace SdxCore.Caching;

public class CacheOptions
{
    public TimeSpan L1Ttl { get; set; } = TimeSpan.FromMinutes(10);
    public TimeSpan L2Ttl { get; set; } = TimeSpan.FromHours(1);
    
    // Static configurations for common data types
    public static CacheOptions Default => new CacheOptions();
    
    public static CacheOptions StaticMasterData => new CacheOptions
    {
        L1Ttl = TimeSpan.FromMinutes(15),
        L2Ttl = TimeSpan.FromHours(2)
    };
    
    public static CacheOptions SessionData => new CacheOptions
    {
        L1Ttl = TimeSpan.FromMinutes(1),
        L2Ttl = TimeSpan.FromMinutes(60)
    };
}
