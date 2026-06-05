using System.Linq;

namespace SdxCore.Common.Helpers;

public static class PropertyMapper
{
    public static TDest Map<TSource, TDest>(TSource source)
    {
        ArgumentNullException.ThrowIfNull(source);

        var dest = (TDest)System.Activator.CreateInstance<TDest>()!;
        MapProperties(source, dest);
        return dest;
    }

    public static void MapProperties<TSource, TDest>(TSource source, TDest dest)
    {
        var sourceProps = typeof(TSource).GetProperties();
        var destProps = typeof(TDest).GetProperties();

        foreach (var sp in sourceProps)
        {
            var dp = destProps.FirstOrDefault(x => x.Name == sp.Name && x.PropertyType == sp.PropertyType);
            if (dp != null && dp.CanWrite)
            {
                dp.SetValue(dest, sp.GetValue(source));
            }
        }
    }
    public static TDest MapToRecord<TDest>(object source)
    {
        ArgumentNullException.ThrowIfNull(source);
        var json = System.Text.Json.JsonSerializer.Serialize(source);
        var options = new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        return System.Text.Json.JsonSerializer.Deserialize<TDest>(json, options)!;
    }

    public static IEnumerable<TDest> MapList<TSource, TDest>(IEnumerable<TSource> sourceList)
    {
        if (sourceList == null) return Enumerable.Empty<TDest>();
        return sourceList.Select(Map<TSource, TDest>).ToList();
    }
}
