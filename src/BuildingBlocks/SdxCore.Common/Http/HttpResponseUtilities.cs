using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using System.Text.Json;

namespace SdxCore.Common.Http;

/// <summary>
/// Utility class for writing standardized HTTP responses across microservices.
/// </summary>
public static class HttpResponseUtilities
{
    /// <summary>
    /// Default JSON serializer options for consistent response formatting.
    /// </summary>
    public static readonly JsonSerializerOptions DefaultJsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

    /// <summary>
    /// Writes a standardized error response to the HTTP context.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="statusCode">The HTTP status code to return.</param>
    /// <param name="errorCode">Machine-readable error code.</param>
    /// <param name="errorMessage">Human-readable error message.</param>
    /// <param name="details">Optional additional error details.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static async Task WriteErrorResponseAsync(
        HttpContext context, 
        int statusCode, 
        string errorCode, 
        string errorMessage,
        object? details = null,
        CancellationToken cancellationToken = default)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        var errorResponse = new ErrorResponse
        {
            ErrorCode = errorCode,
            ErrorMessage = errorMessage,
            Timestamp = DateTimeOffset.UtcNow,
            Details = details
        };

        var json = JsonSerializer.Serialize(errorResponse, DefaultJsonOptions);
        await context.Response.WriteAsync(json, cancellationToken);
    }

    /// <summary>
    /// Writes an unauthorized (401) error response.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="errorCode">Machine-readable error code.</param>
    /// <param name="errorMessage">Human-readable error message.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static Task WriteUnauthorizedResponseAsync(
        HttpContext context, 
        string errorCode, 
        string errorMessage,
        CancellationToken cancellationToken = default)
    {
        return WriteErrorResponseAsync(context, StatusCodes.Status401Unauthorized, errorCode, errorMessage, cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Writes a forbidden (403) error response.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="errorCode">Machine-readable error code.</param>
    /// <param name="errorMessage">Human-readable error message.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static Task WriteForbiddenResponseAsync(
        HttpContext context, 
        string errorCode, 
        string errorMessage,
        CancellationToken cancellationToken = default)
    {
        return WriteErrorResponseAsync(context, StatusCodes.Status403Forbidden, errorCode, errorMessage, cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Writes a bad request (400) error response.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="errorCode">Machine-readable error code.</param>
    /// <param name="errorMessage">Human-readable error message.</param>
    /// <param name="details">Optional validation details.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static Task WriteBadRequestResponseAsync(
        HttpContext context, 
        string errorCode, 
        string errorMessage,
        object? details = null,
        CancellationToken cancellationToken = default)
    {
        return WriteErrorResponseAsync(context, StatusCodes.Status400BadRequest, errorCode, errorMessage, details, cancellationToken);
    }

    /// <summary>
    /// Writes an internal server error (500) response.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="errorCode">Machine-readable error code.</param>
    /// <param name="errorMessage">Human-readable error message.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static Task WriteInternalServerErrorResponseAsync(
        HttpContext context, 
        string errorCode, 
        string errorMessage,
        CancellationToken cancellationToken = default)
    {
        return WriteErrorResponseAsync(context, StatusCodes.Status500InternalServerError, errorCode, errorMessage, cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Writes a successful JSON response.
    /// </summary>
    /// <param name="context">The HTTP context to write the response to.</param>
    /// <param name="data">The data to serialize and return.</param>
    /// <param name="statusCode">The HTTP status code (defaults to 200 OK).</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    public static async Task WriteJsonResponseAsync<T>(
        HttpContext context, 
        T data, 
        int statusCode = StatusCodes.Status200OK,
        CancellationToken cancellationToken = default)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        var json = JsonSerializer.Serialize(data, DefaultJsonOptions);
        await context.Response.WriteAsync(json, cancellationToken);
    }
}