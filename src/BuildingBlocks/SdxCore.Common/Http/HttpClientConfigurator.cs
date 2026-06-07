using SdxCore.Common.Options;

namespace SdxCore.Common.Http;
public static class HttpClientConfigurator
{
    public static void Configure(HttpClient client, ClientOptions options)
    {
        client.BaseAddress = new Uri(options.BaseUrl);
        client.Timeout = TimeSpan.FromSeconds(options.TimeoutSeconds);
    }
}
