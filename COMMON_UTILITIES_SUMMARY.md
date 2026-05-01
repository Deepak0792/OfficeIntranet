# Common Utilities Migration Summary

This document summarizes the useful methods and utilities that have been moved to the `SdxCore.Common` project for reuse across multiple microservices.

## What Was Moved

### 1. Models (src/BuildingBlocks/SdxCore.Common/Models/)

#### ErrorResponse
- **Source**: Previously duplicated in AuthController and GatewayAuthenticationMiddleware
- **Purpose**: Standardized error response format across all microservices
- **Usage**: Consistent error reporting with error codes, messages, timestamps, and optional details

#### TokenValidationResponse
- **Source**: Previously duplicated in AuthController and GatewayAuthenticationMiddleware
- **Purpose**: Standard response format for token validation between Gateway and Identity service
- **Usage**: Communication protocol for internal token validation

#### TokenClaims
- **Source**: Previously internal class in AuthController
- **Purpose**: Structured representation of JWT token claims
- **Usage**: Helper model for token claim extraction and processing

### 2. Security Utilities (src/BuildingBlocks/SdxCore.Common/Security/)

#### InternalApiKeyValidator
- **Source**: `IsInternalGatewayCall()` method from AuthController
- **Purpose**: Validates internal API key calls between microservices
- **Key Methods**:
  - `IsInternalServiceCall()` - General internal service validation
  - `IsInternalGatewayCall()` - Specific Gateway validation
- **Usage**: Secure service-to-service communication

#### JwtTokenUtilities
- **Source**: `ExtractTokenClaims()` method from AuthController
- **Purpose**: Common JWT token operations
- **Key Methods**:
  - `ExtractTokenClaims()` - Extract claims from validated tokens
  - `ExtractBearerToken()` - Extract token from Authorization header
  - `IsValidJwtFormat()` - Validate JWT format without cryptographic validation
- **Usage**: Token parsing and validation across services

### 3. HTTP Utilities (src/BuildingBlocks/SdxCore.Common/Http/)

#### HttpResponseUtilities
- **Source**: `WriteUnauthorizedResponse()` method from GatewayAuthenticationMiddleware
- **Purpose**: Standardized HTTP response writing
- **Key Methods**:
  - `WriteErrorResponseAsync()` - Generic error response
  - `WriteUnauthorizedResponseAsync()` - 401 responses
  - `WriteForbiddenResponseAsync()` - 403 responses
  - `WriteBadRequestResponseAsync()` - 400 responses
  - `WriteInternalServerErrorResponseAsync()` - 500 responses
  - `WriteJsonResponseAsync()` - Success responses
- **Usage**: Consistent response formatting across all services

### 4. Routing Utilities (src/BuildingBlocks/SdxCore.Common/Routing/)

#### PublicRouteValidator
- **Source**: `LoadPublicRoutes()` and `IsPublicRoute()` methods from GatewayAuthenticationMiddleware
- **Purpose**: Consistent public route validation
- **Key Methods**:
  - `IsPublicRoute()` - Check if path is public
  - `GetPublicRoutes()` - Get all configured public routes
- **Usage**: Authentication bypass for public endpoints

### 5. Extensions (src/BuildingBlocks/SdxCore.Common/Extensions/)

#### HttpContextExtensions
- **Source**: New utility methods for accessing Gateway-set headers
- **Purpose**: Easy access to user context from Gateway
- **Key Methods**:
  - `GetUserIdFromGateway()` - Extract user ID from X-User-Id header
  - `GetUsernameFromGateway()` - Extract username from X-Username header
  - `GetUserEmailFromGateway()` - Extract email from X-User-Email header
  - `GetUserRolesFromGateway()` - Extract roles from X-User-Roles header
  - `GetAuthProviderFromGateway()` - Extract provider from X-Auth-Provider header
  - `GetBearerToken()` - Extract bearer token from Authorization header
  - `HasGatewayUserContext()` - Check if request has Gateway user context
  - `GetClientIpAddress()` - Get client IP considering proxy headers
  - `IsLocalRequest()` - Check if request is from localhost
- **Usage**: Access user information in downstream services

## Updated Projects

### Identity API (src/Services/Identity/SdxCore.Identity.API/)
- **Changes**: 
  - Added reference to SdxCore.Common
  - Replaced `IsInternalGatewayCall()` with `InternalApiKeyValidator.IsInternalGatewayCall()`
  - Replaced `ExtractTokenClaims()` with `JwtTokenUtilities.ExtractTokenClaims()`
  - Removed duplicate model definitions (ErrorResponse, TokenValidationResponse, TokenClaims)
  - Added using statements for Common utilities

### Gateway API (src/Gateway/SdxCore.Gateway.API/)
- **Changes**:
  - Added reference to SdxCore.Common
  - Replaced `LoadPublicRoutes()` and `IsPublicRoute()` with `PublicRouteValidator`
  - Replaced `WriteUnauthorizedResponse()` with `HttpResponseUtilities.WriteUnauthorizedResponseAsync()`
  - Removed duplicate TokenValidationResponse model
  - Added using statements for Common utilities

## Benefits

### 1. Code Reusability
- Common functionality is now shared across microservices
- Reduces code duplication and maintenance overhead
- Ensures consistent behavior across services

### 2. Standardization
- Consistent error response format across all services
- Standardized security validation patterns
- Uniform HTTP response handling

### 3. Maintainability
- Single source of truth for common utilities
- Easier to update and fix issues across all services
- Better testability with isolated utility classes

### 4. Security
- Centralized security validation logic
- Consistent internal API key validation
- Standardized token handling

## Usage Examples

### In Controllers
```csharp
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Common.Extensions;

[HttpPost("internal-endpoint")]
public IActionResult InternalEndpoint()
{
    if (!InternalApiKeyValidator.IsInternalGatewayCall(Request, _configuration, _logger))
    {
        return StatusCode(403, new ErrorResponse
        {
            ErrorCode = "FORBIDDEN",
            ErrorMessage = "This endpoint is only accessible by the Gateway"
        });
    }

    var userId = HttpContext.GetUserIdFromGateway();
    var roles = HttpContext.GetUserRolesFromGateway();
    
    return Ok(new { UserId = userId, Roles = roles });
}
```

### In Middleware
```csharp
using SdxCore.Common.Routing;
using SdxCore.Common.Http;

public async Task InvokeAsync(HttpContext context)
{
    if (_routeValidator.IsPublicRoute(context.Request.Path))
    {
        await _next(context);
        return;
    }

    if (!context.HasGatewayUserContext())
    {
        await HttpResponseUtilities.WriteUnauthorizedResponseAsync(
            context, "AUTHENTICATION_REQUIRED", "Authentication required");
        return;
    }

    await _next(context);
}
```

## Configuration

### Required Configuration
```json
{
  "Authentication": {
    "InternalApiKey": "your-secure-internal-api-key",
    "PublicRoutes": [
      "/health",
      "/api/auth/login",
      "/swagger/*"
    ]
  }
}
```

## Next Steps

1. **Add Common Reference**: Other microservices should add a reference to SdxCore.Common
2. **Migrate Duplicate Code**: Look for similar patterns in other services and migrate them
3. **Update Documentation**: Update service-specific documentation to reference common utilities
4. **Testing**: Ensure all services work correctly with the new common utilities
5. **Monitoring**: Monitor for any issues after deployment

## Files Created

- `src/BuildingBlocks/SdxCore.Common/Models/ErrorResponse.cs`
- `src/BuildingBlocks/SdxCore.Common/Models/TokenValidationResponse.cs`
- `src/BuildingBlocks/SdxCore.Common/Models/TokenClaims.cs`
- `src/BuildingBlocks/SdxCore.Common/Security/InternalApiKeyValidator.cs`
- `src/BuildingBlocks/SdxCore.Common/Security/JwtTokenUtilities.cs`
- `src/BuildingBlocks/SdxCore.Common/Http/HttpResponseUtilities.cs`
- `src/BuildingBlocks/SdxCore.Common/Routing/PublicRouteValidator.cs`
- `src/BuildingBlocks/SdxCore.Common/Extensions/HttpContextExtensions.cs`
- `src/BuildingBlocks/SdxCore.Common/Examples/SampleController.cs`
- `src/BuildingBlocks/SdxCore.Common/README.md`

## Dependencies Added

- Microsoft.AspNetCore.Http.Abstractions
- Microsoft.Extensions.Configuration.Abstractions
- Microsoft.Extensions.Configuration.Binder
- Microsoft.Extensions.Logging.Abstractions
- System.IdentityModel.Tokens.Jwt
- System.Text.Json