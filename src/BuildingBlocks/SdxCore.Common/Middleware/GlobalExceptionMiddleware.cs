using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;

namespace SdxCore.Common.Middleware;

public class GlobalExceptionMiddleware
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
            _logger.LogError(ex, "An unhandled exception occurred during the request.");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var statusCode = HttpStatusCode.InternalServerError;
        var errorCode = "INTERNAL_SERVER_ERROR";
        var message = "An unexpected error occurred while processing the request.";

        var exceptionType = exception.GetType().Name;

        if (exceptionType.EndsWith("NotFoundException", StringComparison.OrdinalIgnoreCase))
        {
            statusCode = HttpStatusCode.NotFound;
            errorCode = "NOT_FOUND";
            message = exception.Message;
        }
        else if (exceptionType.Contains("Duplicate", StringComparison.OrdinalIgnoreCase) ||
                 exceptionType.EndsWith("ValidationException", StringComparison.OrdinalIgnoreCase))
        {
            statusCode = HttpStatusCode.BadRequest;
            errorCode = "BAD_REQUEST";
            message = exception.Message;
        }
        else if (exceptionType.EndsWith("UnauthorizedException", StringComparison.OrdinalIgnoreCase))
        {
            statusCode = HttpStatusCode.Unauthorized;
            errorCode = "UNAUTHORIZED";
            message = exception.Message;
        }
        else if (exceptionType.EndsWith("ForbiddenException", StringComparison.OrdinalIgnoreCase))
        {
            statusCode = HttpStatusCode.Forbidden;
            errorCode = "FORBIDDEN";
            message = exception.Message;
        }
        else if (exceptionType.EndsWith("DomainException", StringComparison.OrdinalIgnoreCase) ||
                 exceptionType.EndsWith("Exception", StringComparison.OrdinalIgnoreCase) && statusCode == HttpStatusCode.InternalServerError && exception.Message != null && exception.GetType().Namespace?.Contains("Domain") == true)
        {
             // For domain exceptions that don't match specific patterns but reside in Domain namespace
             statusCode = HttpStatusCode.BadRequest;
             errorCode = "DOMAIN_ERROR";
             message = exception.Message;
        }

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        var errorResponse = new ErrorResponse
        {
            ErrorCode = errorCode,
            ErrorMessage = message,
            Timestamp = DateTime.UtcNow
        };

        var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
        var json = JsonSerializer.Serialize(errorResponse, options);

        return context.Response.WriteAsync(json);
    }
}
