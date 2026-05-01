# SdxCore.Common

This project contains shared utilities and models that are used across multiple microservices in the SdxCore system.

## Overview

The Common project provides reusable components to ensure consistency and reduce code duplication across microservices. It includes security utilities, HTTP response helpers, routing validators, and common data models.

## Components

### Models

#### `ErrorResponse`
Standard error response model used across all microservices for consistent error reporting.

```csharp
var error = new ErrorResponse
{
    ErrorCode = "VALIDATION_FAILED",
    ErrorMessage = "The request data is invalid",
    Timestamp = DateTimeOffset.UtcNow,
    Details = validationErrors
};
```

#### `TokenValidationResponse`
Response model for token validation between Gateway and Identity service.

#### `TokenClaims`
Helper model for representing JWT token claims in a structured way.

### Security

#### `InternalApiKeyValidator`
Validates internal API key calls between microservices.

```csharp
// In a controller
if (!InternalApiKeyValidator.IsInternalGatewayCall(Request, _configuration, _logger))
{
    return Forbid();
}
```

#### `JwtTokenUtilities`
Utilities for working with JWT tokens.

```csharp
// Extract claims from a validated token
var claims = JwtTokenUtilities.ExtractTokenClaims(token, _logger);

// Extract bearer token from Authorization header
var token = JwtTokenUtilities.ExtractBearerToken(authHeader);

// Validate JWT format (without cryptographic validation)
if (JwtTokenUtilities.IsValidJwtFormat(token))
{
    // Process token
}
```

### HTTP

#### `HttpResponseUtilities`
Standardized HTTP response writing utilities.

```csharp
// Write error responses
await HttpResponseUtilities.WriteUnauthorizedResponseAsync(context, "INVALID_TOKEN", "Token is expired");
await HttpResponseUtilities.WriteBadRequestResponseAsync(context, "VALIDATION_ERROR", "Invalid input", validationDetails);

// Write success responses
await HttpResponseUtilities.WriteJsonResponseAsync(context, responseData);
```

### Routing

#### `PublicRouteValidator`
Validates public routes that don't require authentication.

```csharp
var validator = new PublicRouteValidator(_configuration, _logger);

if (validator.IsPublicRoute("/api/auth/login"))
{
    // Allow public access
}
```

### Extensions

#### `HttpContextExtensions`
Extension methods for HttpContext to access user information set by the Gateway.

```csharp
// Get user information from Gateway headers
var userId = context.GetUserIdFromGateway();
var username = context.GetUsernameFromGateway();
var roles = context.GetUserRolesFromGateway();

// Check if request has Gateway user context
if (context.HasGatewayUserContext())
{
    // Request was authenticated by Gateway
}

// Get client IP (considering proxy headers)
var clientIp = context.GetClientIpAddress();
```

## Configuration

### Internal API Key

The internal API key is used for service-to-service authentication. Configure it in `appsettings.json`:

```json
{
  "Authentication": {
    "InternalApiKey": "your-secure-internal-api-key-here"
  }
}
```

### Public Routes

Configure public routes that don't require authentication:

```json
{
  "Authentication": {
    "PublicRoutes": [
      "/health",
      "/api/auth/login",
      "/swagger/*",
      "/docs/*"
    ]
  }
}
```

## Usage in Microservices

### Adding Reference

Add a project reference to your microservice:

```xml
<ProjectReference Include="..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
```

### Using in Controllers

```csharp
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Common.Extensions;

[ApiController]
public class MyController : ControllerBase
{
    [HttpPost("internal-endpoint")]
    public IActionResult InternalEndpoint()
    {
        // Validate internal call
        if (!InternalApiKeyValidator.IsInternalServiceCall(Request, _configuration, _logger))
        {
            return StatusCode(403, new ErrorResponse
            {
                ErrorCode = "FORBIDDEN",
                ErrorMessage = "This endpoint is only accessible internally"
            });
        }

        // Get user context from Gateway
        var userId = HttpContext.GetUserIdFromGateway();
        var roles = HttpContext.GetUserRolesFromGateway();

        return Ok(new { UserId = userId, Roles = roles });
    }
}
```

### Using in Middleware

```csharp
using SdxCore.Common.Routing;
using SdxCore.Common.Http;

public class MyMiddleware
{
    private readonly PublicRouteValidator _routeValidator;

    public MyMiddleware(RequestDelegate next, IConfiguration configuration, ILogger<MyMiddleware> logger)
    {
        _routeValidator = new PublicRouteValidator(configuration, logger);
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (_routeValidator.IsPublicRoute(context.Request.Path))
        {
            await _next(context);
            return;
        }

        // Require authentication for non-public routes
        if (!context.HasGatewayUserContext())
        {
            await HttpResponseUtilities.WriteUnauthorizedResponseAsync(
                context, "AUTHENTICATION_REQUIRED", "This endpoint requires authentication");
            return;
        }

        await _next(context);
    }
}
```

## Best Practices

1. **Error Responses**: Always use `ErrorResponse` for consistent error formatting
2. **Internal API Keys**: Use `InternalApiKeyValidator` for service-to-service authentication
3. **JWT Tokens**: Use `JwtTokenUtilities` for token parsing and validation
4. **HTTP Responses**: Use `HttpResponseUtilities` for standardized response writing
5. **User Context**: Use `HttpContextExtensions` to access user information from Gateway headers
6. **Public Routes**: Use `PublicRouteValidator` for consistent route access control

## Dependencies

- Microsoft.AspNetCore.Http.Abstractions
- Microsoft.Extensions.Configuration.Abstractions
- Microsoft.Extensions.Logging.Abstractions
- System.IdentityModel.Tokens.Jwt
- System.Text.Json