using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;
using System.Text.Json;

namespace SdxCore.Attendance.API.Middleware;

public class AttendanceExceptionMiddleware(RequestDelegate next, ILogger<AttendanceExceptionMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (InvalidOperationException ex)
        {
            logger.LogWarning(ex, "Domain exception: {Message}", ex.Message);
            await WriteErrorAsync(context, StatusCodes.Status400BadRequest, "DOMAIN_ERROR", ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            logger.LogWarning(ex, "Not found: {Message}", ex.Message);
            await WriteErrorAsync(context, StatusCodes.Status404NotFound, "NOT_FOUND", ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception");
            await WriteErrorAsync(context, StatusCodes.Status500InternalServerError, "INTERNAL_ERROR", "An unexpected error occurred.");
        }
    }

    private static async Task WriteErrorAsync(HttpContext context, int statusCode, string errorCode, string message)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";
        var response = new ErrorResponse { ErrorCode = errorCode, ErrorMessage = message };
        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
