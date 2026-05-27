using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Caching;

public class CacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    private readonly ILogger<CacheService> _logger;

    private static readonly ConcurrentDictionary<string, byte> _trackedKeys = new();

    public CacheService(IMemoryCache memoryCache, IDistributedCache distributedCache, ILogger<CacheService> logger)
    {
        _memoryCache = memoryCache;
        _distributedCache = distributedCache;
        _logger = logger;
    }

    public async Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default)
    {
        if (_memoryCache.TryGetValue(key, out T? memoryValue))
        {
            _logger.LogDebug("L1 Cache hit for key: {Key}", key);
            return memoryValue;
        }

        var distributedValueBytes = await _distributedCache.GetAsync(key, cancellationToken);
        if (distributedValueBytes != null)
        {
            _logger.LogDebug("L2 Cache hit for key: {Key}", key);
            var distributedValue = JsonSerializer.Deserialize<T>(distributedValueBytes);
            
            if (distributedValue != null)
            {
                var options = new MemoryCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5) };
                _memoryCache.Set(key, distributedValue, options);
            }
            return distributedValue;
        }

        _logger.LogDebug("Cache miss for key: {Key}", key);
        return default;
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? slidingExpiration = null, TimeSpan? absoluteExpiration = null, CancellationToken cancellationToken = default)
    {
        var options = new DistributedCacheEntryOptions
        {
            SlidingExpiration = slidingExpiration,
            AbsoluteExpirationRelativeToNow = absoluteExpiration ?? TimeSpan.FromHours(1)
        };

        var memoryOptions = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
        };

        _memoryCache.Set(key, value, memoryOptions);

        var bytes = JsonSerializer.SerializeToUtf8Bytes(value);
        await _distributedCache.SetAsync(key, bytes, options, cancellationToken);
        
        _trackedKeys.TryAdd(key, 1);
    }

    public async Task RemoveAsync(string key, CancellationToken cancellationToken = default)
    {
        _memoryCache.Remove(key);
        await _distributedCache.RemoveAsync(key, cancellationToken);
        _trackedKeys.TryRemove(key, out _);
    }

    public async Task RemoveByPrefixAsync(string prefixKey, CancellationToken cancellationToken = default)
    {
        foreach (var key in _trackedKeys.Keys)
        {
            if (key.StartsWith(prefixKey, StringComparison.OrdinalIgnoreCase))
            {
                await RemoveAsync(key, cancellationToken);
            }
        }
    }

    public async Task<T> GetOrSetAsync<T>(string key, Func<CancellationToken, Task<T>> factory, TimeSpan? slidingExpiration = null, TimeSpan? absoluteExpiration = null, CancellationToken cancellationToken = default)
    {
        var cachedValue = await GetAsync<T>(key, cancellationToken);
        if (cachedValue != null)
            return cachedValue;

        var value = await factory(cancellationToken);
        if (value != null)
        {
            await SetAsync(key, value, slidingExpiration, absoluteExpiration, cancellationToken);
        }
        return value!;
    }
}
