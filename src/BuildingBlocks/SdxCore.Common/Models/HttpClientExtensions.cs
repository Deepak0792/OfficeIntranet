using System.Net.Http.Json;
using SdxCore.Common.Models;

public static class HttpClientExtensions
{
    public static async Task<T?> ReadApiResponseAsync<T>(
        this HttpResponseMessage response,
        CancellationToken cancellationToken = default)
    {
        response.EnsureSuccessStatusCode();

        var apiResponse =
            await response.Content.ReadFromJsonAsync<ApiResponse<T>>(
                cancellationToken: cancellationToken);

        if (apiResponse is null)
            throw new InvalidOperationException("Empty response received.");

        if (!apiResponse.Succeeded)
            throw new InvalidOperationException(
                apiResponse.Message ?? "Request failed.");

        return apiResponse.Data;
    }
}