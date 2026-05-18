using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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
    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var configuration = context.HttpContext.RequestServices.GetRequiredService<IConfiguration>();
        var loggerFactory = context.HttpContext.RequestServices.GetRequiredService<ILoggerFactory>();
        var logger = loggerFactory.CreateLogger<GatewayOnlyAttribute>();

        if (!InternalApiKeyValidator.IsInternalGatewayCall(context.HttpContext.Request, configuration, logger))
        {
            var errorResponse = new ErrorResponse
            {
                ErrorCode = "FORBIDDEN",
                ErrorMessage = "This endpoint is only accessible by the Gateway"
            };

            context.Result = new ObjectResult(errorResponse)
            {
                StatusCode = Microsoft.AspNetCore.Http.StatusCodes.Status403Forbidden
            };

            return;
        }

        await next();
    }
}
