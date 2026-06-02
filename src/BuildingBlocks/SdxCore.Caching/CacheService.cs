using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;
using System.Text.Json;

namespace SdxCore.Caching;

public class CacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    private readonly IConnectionMultiplexer _redisConnection;
    private readonly ILogger<CacheService> _logger;

    public CacheService(
        IMemoryCache memoryCache,
        IDistributedCache distributedCache,
        IConnectionMultiplexer redisConnection,
        ILogger<CacheService> logger)
    {
        _memoryCache = memoryCache;
        _distributedCache = distributedCache;
        _redisConnection = redisConnection;
        _logger = logger;
    }

    public async Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default)
    {
        // 1. Check L1 Cache
        if (_memoryCache.TryGetValue(key, out T? l1Value))
        {
            _logger.LogDebug("L1 Cache hit for key: {Key}", key);
            return l1Value;
        }

        // 2. Check L2 Cache
        var l2Bytes = await _distributedCache.GetAsync(key, cancellationToken);
        if (l2Bytes != null && l2Bytes.Length > 0)
        {
            try
            {
                var l2Value = JsonSerializer.Deserialize<T>(l2Bytes);
                if (l2Value != null)
                {
                    _logger.LogDebug("L2 Cache hit for key: {Key}", key);
                    
                    // Backfill L1 Cache with default options
                    _memoryCache.Set(key, l2Value, CacheOptions.Default.L1Ttl);
                    
                    return l2Value;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to deserialize L2 cache value for key: {Key}", key);
            }
        }

        _logger.LogDebug("Cache miss for key: {Key}", key);
        return default;
    }

    public async Task<T> GetOrSetAsync<T>(string key, Func<CancellationToken, Task<T>> factory, CacheOptions? options = null, CancellationToken cancellationToken = default)
    {
        var value = await GetAsync<T>(key, cancellationToken);
        if (value != null)
        {
            return value;
        }

        // Execute factory
        value = await factory(cancellationToken);

        if (value != null)
        {
            await SetAsync(key, value, options, cancellationToken);
        }

        return value;
    }

    public async Task SetAsync<T>(string key, T value, CacheOptions? options = null, CancellationToken cancellationToken = default)
    {
        options ??= CacheOptions.Default;

        // Set L1
        _memoryCache.Set(key, value, options.L1Ttl);

        // Set L2
        var jsonBytes = JsonSerializer.SerializeToUtf8Bytes(value);
        var distOptions = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = options.L2Ttl
        };
        
        await _distributedCache.SetAsync(key, jsonBytes, distOptions, cancellationToken);
        _logger.LogDebug("Cache set for key: {Key}", key);
    }

    public async Task RemoveAsync(string key, CancellationToken cancellationToken = default)
    {
        _memoryCache.Remove(key);
        await _distributedCache.RemoveAsync(key, cancellationToken);
        _logger.LogDebug("Cache removed for key: {Key}", key);
    }

    public async Task RemoveByPatternAsync(string pattern, CancellationToken cancellationToken = default)
    {
        var endpoints = _redisConnection.GetEndPoints();
        foreach (var endpoint in endpoints)
        {
            var server = _redisConnection.GetServer(endpoint);
            var keys = server.Keys(pattern: pattern);
            
            var db = _redisConnection.GetDatabase();
            foreach (var key in keys)
            {
                await db.KeyDeleteAsync(key);
                _memoryCache.Remove(key.ToString());
            }
        }
        
        _logger.LogDebug("Cache removed for pattern: {Pattern}", pattern);
    }
}
