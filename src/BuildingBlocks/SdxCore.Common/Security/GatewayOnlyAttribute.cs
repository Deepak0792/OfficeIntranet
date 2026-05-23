using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;

namespace SdxCore.Common.Security;

/// <summary>
/// An action filter that restricts access to endpoints so they can only be called via the Gateway.
/// It uses the InternalApiKeyValidator to check for the presence of a valid internal API key.
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public sealed class GatewayOnlyAttribute : Attribute, IAsyncActionFilter
{
   public async Task OnActionExecutionAsync(
    ActionExecutingContext context,
    ActionExecutionDelegate next)
    {
        var services = context.HttpContext.RequestServices;

        var configuration = services.GetRequiredService<IConfiguration>();
        var loggerFactory = services.GetRequiredService<ILoggerFactory>();
        var environment = services.GetRequiredService<IWebHostEnvironment>();

        var logger = loggerFactory.CreateLogger<GatewayOnlyAttribute>();

        // Skip validation in Development environment
        if (!environment.IsDevelopment())
        {
            if (!InternalApiKeyValidator.IsInternalGatewayCall(
                    context.HttpContext.Request,
                    configuration,
                    logger))
            {
                var errorResponse = new ErrorResponse
                {
                    ErrorCode = "FORBIDDEN",
                    ErrorMessage = "Access denied. This endpoint is only accessible through the API Gateway."
                };

                context.Result = new ObjectResult(errorResponse)
                {
                    StatusCode = StatusCodes.Status403Forbidden
                };

                return;
            }
        }

        await next();
    }
}
