using System.Linq;

namespace SdxCore.Time.Application.Helpers;

public static class SimpleMapper
{
    public static TDest? Map<TSource, TDest>(TSource source)
    {
        if (source == null) return default;
        var dest = (TDest)System.Activator.CreateInstance(typeof(TDest))!;
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
}
