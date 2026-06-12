using SdxCore.Common.Models;
using SdxCore.Identity.Application.Exceptions;
using System.Net;
using System.Text.Json;

namespace SdxCore.Identity.API.Middleware;

/// <summary>
/// Centralized exception handling middleware for the Identity service.
/// Maps domain exceptions to standardized HTTP responses — eliminates per-action try/catch.
/// </summary>
public sealed class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception for {Method} {Path}", context.Request.Method, context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, errorCode, message) = exception switch
        {
            RecordNotFoundException ex      => (HttpStatusCode.NotFound,            "NOT_FOUND",                ex.Message),
            AuthProviderUnavailableException ex => (HttpStatusCode.ServiceUnavailable, "PROVIDER_UNAVAILABLE",  ex.Message),
            ProviderNotFoundException ex    => (HttpStatusCode.InternalServerError,  "PROVIDER_NOT_FOUND",      ex.Message),
            ConfigurationException ex       => (HttpStatusCode.InternalServerError,  "CONFIGURATION_ERROR",     ex.Message),
            ArgumentNullException ex        => (HttpStatusCode.BadRequest,           "INVALID_ARGUMENT",        ex.Message),
            InvalidOperationException ex    => (HttpStatusCode.Conflict,             "CONFLICT",                ex.Message),
            UnauthorizedAccessException ex  => (HttpStatusCode.Unauthorized,         "UNAUTHORIZED",            ex.Message),
            _                               => (HttpStatusCode.InternalServerError,  "INTERNAL_ERROR",          "An unexpected error occurred.")
        };

        var error = new ErrorResponse
        {
            ErrorCode = errorCode,
            ErrorMessage = message
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        return context.Response.WriteAsync(JsonSerializer.Serialize(error, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        }));
    }
}

/// <summary>Extension method for registering GlobalExceptionMiddleware.</summary>
public static class GlobalExceptionMiddlewareExtensions
{
    public static IApplicationBuilder UseGlobalExceptionHandler(this IApplicationBuilder builder)
        => builder.UseMiddleware<GlobalExceptionMiddleware>();
}
