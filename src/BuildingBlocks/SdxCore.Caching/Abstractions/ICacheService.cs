namespace SdxCore.Caching;

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default);
    Task<T> GetOrSetAsync<T>(string key, Func<CancellationToken, Task<T>> factory, CacheOptions? options = null, CancellationToken cancellationToken = default);
    Task SetAsync<T>(string key, T value, CacheOptions? options = null, CancellationToken cancellationToken = default);
    Task RemoveAsync(string key, CancellationToken cancellationToken = default);
    Task RemoveByPatternAsync(string pattern, CancellationToken cancellationToken = default);
}
