using System.Collections.Concurrent;
using System.Linq.Expressions;
using System.Reflection;

namespace SdxCore.Common.Helpers;

/// <summary>
/// Lightweight, zero-dependency object mapper using cached compiled expression trees.
/// 10–50× faster than reflection-based mapping — delegates are compiled once per type pair and reused.
///
/// Usage:
///   Create:  var entity = PropertyMapper.Map&lt;CreateXyzRequest, XyzEntity&gt;(request);
///   Read:    var dto    = PropertyMapper.Map&lt;XyzEntity, XyzResponse&gt;(entity);
///   List:    var dtos   = PropertyMapper.MapList&lt;XyzEntity, XyzResponse&gt;(entities);
///   Update:  PropertyMapper.Patch&lt;UpdateXyzRequest, XyzEntity&gt;(request, entity);
///
/// Rules:
///   - Properties are matched by name (case-sensitive) and type.
///   - Patch() performs a full overwrite — nulls from source overwrite destination values.
///   - Audit fields (CreatedAt, CreatedBy, LastUpdatedAt, LastUpdatedBy) are set by interceptors — never set them in mappers.
///   - Fields not present on both sides are silently skipped.
/// </summary>
public static class PropertyMapper
{
    private static readonly ConcurrentDictionary<(Type Source, Type Dest), Delegate> _cache = new();

    /// <summary>Creates a new <typeparamref name="TDest"/> and copies all matching properties from <paramref name="source"/>.</summary>
    public static TDest Map<TSource, TDest>(TSource source)
    {
        ArgumentNullException.ThrowIfNull(source);
        var copier = GetCopier<TSource, TDest>();
        var dest = Activator.CreateInstance<TDest>();
        copier(source, dest);
        return dest;
    }

    /// <summary>
    /// Copies all matching properties from <paramref name="source"/> onto an existing <paramref name="dest"/> (full overwrite).
    /// Use for Update operations — replaces the old MapProperties method.
    /// </summary>
    public static void Patch<TSource, TDest>(TSource source, TDest dest)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(dest);
        GetCopier<TSource, TDest>()(source, dest);
    }

    /// <summary>Maps a collection of <typeparamref name="TSource"/> to a <see cref="List{TDest}"/>.</summary>
    public static IEnumerable<TDest> MapList<TSource, TDest>(IEnumerable<TSource> sourceList)
    {
        if (sourceList is null) return [];
        return sourceList.Select(Map<TSource, TDest>);
    }

    // ── Internal ──────────────────────────────────────────────────────────────

    private static Action<TSource, TDest> GetCopier<TSource, TDest>()
    {
        return (Action<TSource, TDest>)_cache.GetOrAdd(
            (typeof(TSource), typeof(TDest)),
            _ => BuildCopier<TSource, TDest>());
    }

    private static Action<TSource, TDest> BuildCopier<TSource, TDest>()
    {
        var srcParam = Expression.Parameter(typeof(TSource), "src");
        var dstParam = Expression.Parameter(typeof(TDest), "dst");

        var srcProps = typeof(TSource)
            .GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(p => p.CanRead)
            .ToDictionary(p => p.Name);

        var assignments = typeof(TDest)
            .GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(dp =>
                dp.CanWrite &&
                srcProps.TryGetValue(dp.Name, out var sp) &&
                sp.PropertyType == dp.PropertyType)
            .Select(dp =>
            {
                var sp = srcProps[dp.Name];
                return (Expression)Expression.Assign(
                    Expression.Property(dstParam, dp),
                    Expression.Property(srcParam, sp));
            })
            .ToList();

        var body = assignments.Count > 0
            ? (Expression)Expression.Block(assignments)
            : Expression.Empty();

        return Expression.Lambda<Action<TSource, TDest>>(body, srcParam, dstParam).Compile();
    }
}
