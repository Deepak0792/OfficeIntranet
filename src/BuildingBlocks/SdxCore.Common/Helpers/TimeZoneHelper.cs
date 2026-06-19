using System.Collections.Concurrent;
using TimeZoneConverter;

namespace SdxCore.Common.Helpers;

public static class TimeZoneHelper
{
    private static readonly ConcurrentDictionary<string, TimeZoneInfo> Cache = new();

    // Overload 1: DateOnly + TimeOnly
    public static DateTime ToUtc(
        DateOnly localDate,
        TimeOnly time,
        string ianaTimeZoneId)
    {
        var localDateTime = localDate.ToDateTime(time);

        return ToUtc(localDateTime, ianaTimeZoneId);
    }

    // Overload 2: DateTime
    public static DateTime ToUtc(
        DateTime localDateTime,
        string ianaTimeZoneId)
    {
        if (string.IsNullOrWhiteSpace(ianaTimeZoneId))
            throw new ArgumentException("Time zone id is required.", nameof(ianaTimeZoneId));

        var timeZone = Cache.GetOrAdd(ianaTimeZoneId, ResolveTimeZone);

        return TimeZoneInfo.ConvertTimeToUtc(localDateTime, timeZone);
    }

    private static TimeZoneInfo ResolveTimeZone(string ianaTimeZoneId)
    {
        try
        {
            var windowsId = TZConvert.IanaToWindows(ianaTimeZoneId);
            return TimeZoneInfo.FindSystemTimeZoneById(windowsId);
        }
        catch (TimeZoneNotFoundException ex)
        {
            throw new InvalidOperationException(
                $"Invalid time zone: '{ianaTimeZoneId}'", ex);
        }
        catch (InvalidTimeZoneException ex)
        {
            throw new InvalidOperationException(
                $"Corrupt time zone data for: '{ianaTimeZoneId}'", ex);
        }
    }
}