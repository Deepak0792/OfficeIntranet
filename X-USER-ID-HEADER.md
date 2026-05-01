# X-User-Id Header Implementation

This document describes the implementation of the `X-User-Id` header functionality in the SdxCore Gateway, which automatically extracts user context from JWT tokens and forwards it to downstream microservices.

## Overview

The Gateway authentication middleware now automatically:
1. **Validates JWT tokens** for protected routes
2. **Extracts user ID** from the JWT token claims
3. **Adds X-User-Id header** to requests forwarded to downstream services
4. **Provides user context** without requiring JWT decoding in each microservice

## Implementation Details

### JWT Claims Supported

The Gateway looks for user ID in the following JWT claims (in order of preference):

1. `sub` - Standard JWT subject claim
2. `NameIdentifier` - ASP.NET Core standard claim type
3. `user_id` - Custom claim
4. `userId` - Custom claim

### Code Flow

```csharp
// 1. Token validation succeeds
var isValid = await ValidateTokenWithIdentityService(token, cancellationToken);

// 2. Extract user ID from JWT token
var userId = ExtractUserIdFromToken(token);

// 3. Add header to forwarded request
if (!string.IsNullOrEmpty(userId))
{
    context.Request.Headers["X-User-Id"] = userId;
}

// 4. Forward request to downstream service
await _next(context);
```

### Header Behavior

| Route Type | Authentication | X-User-Id Header |
|------------|----------------|------------------|
| Public Routes | ❌ Bypassed | ❌ Not Added |
| Protected Routes (Valid Token) | ✅ Required | ✅ Added |
| Protected Routes (Invalid Token) | ❌ Rejected | ❌ Request Blocked |

## Usage in Microservices

### Simple Header Access

```csharp
[HttpGet]
public async Task<IActionResult> GetUserData()
{
    var userId = Request.Headers["X-User-Id"].FirstOrDefault();
    
    if (string.IsNullOrEmpty(userId))
    {
        return BadRequest("User context not available");
    }

    var data = await _service.GetDataForUserAsync(userId);
    return Ok(data);
}
```

### Base Controller Approach

```csharp
public abstract class AuthenticatedControllerBase : ControllerBase
{
    protected string? UserId => Request.Headers["X-User-Id"].FirstOrDefault();
    
    protected string GetRequiredUserId()
    {
        var userId = UserId;
        if (string.IsNullOrEmpty(userId))
        {
            throw new InvalidOperationException("User context is not available");
        }
        return userId;
    }
}

[ApiController]
[Route("api/[controller]")]
public class OrdersController : AuthenticatedControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetOrders()
    {
        var userId = GetRequiredUserId(); // Throws if not available
        var orders = await _orderService.GetOrdersByUserIdAsync(userId);
        return Ok(orders);
    }
}
```

### Middleware Approach

```csharp
public class UserContextMiddleware
{
    private readonly RequestDelegate _next;

    public UserContextMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var userId = context.Request.Headers["X-User-Id"].FirstOrDefault();
        
        if (!string.IsNullOrEmpty(userId))
        {
            context.Items["UserId"] = userId;
        }

        await _next(context);
    }
}

// Register in Program.cs
app.UseMiddleware<UserContextMiddleware>();
```

### Dependency Injection Service

```csharp
public interface IUserContext
{
    string? UserId { get; }
    string GetRequiredUserId();
}

public class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContext(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public string? UserId => _httpContextAccessor.HttpContext?.Items["UserId"] as string;

    public string GetRequiredUserId()
    {
        var userId = UserId;
        if (string.IsNullOrEmpty(userId))
        {
            throw new InvalidOperationException("User context is not available");
        }
        return userId;
    }
}

// Register in Program.cs
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();

// Use in controllers
public class OrdersController : ControllerBase
{
    private readonly IUserContext _userContext;

    public OrdersController(IUserContext userContext)
    {
        _userContext = userContext;
    }

    [HttpGet]
    public async Task<IActionResult> GetOrders()
    {
        var userId = _userContext.GetRequiredUserId();
        var orders = await _orderService.GetOrdersByUserIdAsync(userId);
        return Ok(orders);
    }
}
```

## Benefits

### For Microservices
- **No JWT Decoding**: Services don't need JWT libraries or token parsing logic
- **Simple Access**: Direct header access to user context
- **Performance**: Avoids repeated JWT parsing in each service
- **Consistency**: Standardized user context across all services
- **Security**: User ID extraction happens once at the Gateway level

### For Development
- **Simplified Code**: Less boilerplate code in each microservice
- **Testability**: Easy to mock user context in tests
- **Debugging**: Clear user context in logs and debugging
- **Maintainability**: Centralized user context extraction

## Security Considerations

### Trusted Network
- The `X-User-Id` header should only be trusted from the Gateway
- Microservices should be deployed in a trusted network environment
- Direct access to microservices should be blocked from external clients

### Header Validation
```csharp
// Optional: Validate that request came through Gateway
public class GatewayHeaderValidationMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        // Check for Gateway-specific header or signature
        var gatewaySignature = context.Request.Headers["X-Gateway-Signature"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(gatewaySignature))
        {
            // Request didn't come through Gateway
            context.Response.StatusCode = 403;
            return;
        }

        // Validate signature...
        await next(context);
    }
}
```

### Logging and Monitoring
```csharp
// Log user context for audit trails
_logger.LogInformation("User {UserId} accessed {Endpoint}", userId, context.Request.Path);

// Monitor for missing user context
if (string.IsNullOrEmpty(userId))
{
    _logger.LogWarning("Request to protected endpoint without user context: {Path}", context.Request.Path);
}
```

## Testing

### Unit Tests
```csharp
[Test]
public async Task GetOrders_WithValidUserId_ReturnsOrders()
{
    // Arrange
    var userId = "test-user-123";
    var context = new DefaultHttpContext();
    context.Request.Headers["X-User-Id"] = userId;
    
    var controller = new OrdersController(_mockOrderService.Object)
    {
        ControllerContext = new ControllerContext { HttpContext = context }
    };

    // Act
    var result = await controller.GetOrders();

    // Assert
    var okResult = Assert.IsType<OkObjectResult>(result);
    _mockOrderService.Verify(s => s.GetOrdersByUserIdAsync(userId), Times.Once);
}
```

### Integration Tests
```csharp
[Test]
public async Task Gateway_AddsUserIdHeader_WhenTokenIsValid()
{
    // Arrange
    var token = GenerateValidJwtToken("test-user-123");
    
    // Act
    var response = await _client.GetAsync("/api/orders", request =>
    {
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
    });

    // Assert
    Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    
    // Verify the downstream service received the X-User-Id header
    _mockDownstreamService.Verify(s => s.ReceivedRequest(
        It.Is<HttpRequestMessage>(r => r.Headers.Contains("X-User-Id"))
    ));
}
```

## Troubleshooting

### Common Issues

1. **X-User-Id header is missing**
   - Check that the request went through the Gateway
   - Verify the JWT token contains a supported user ID claim
   - Check Gateway logs for user ID extraction errors

2. **Wrong user ID in header**
   - Verify the JWT token was issued correctly
   - Check which claim type is being used in the token
   - Review the claim extraction logic in the Gateway

3. **Header not accessible in microservice**
   - Ensure the request is going through the Gateway
   - Check that the route is configured as protected (not public)
   - Verify the microservice is reading the correct header name

### Debug Logging

Enable debug logging in the Gateway to see user ID extraction:

```json
{
  "Logging": {
    "LogLevel": {
      "SdxCore.Gateway.API.Middleware": "Debug"
    }
  }
}
```

This will log:
- User ID extraction attempts
- Available claims in JWT tokens
- Header addition success/failure
- Route authentication decisions

## Future Enhancements

### Planned Features
1. **Additional Headers**: Add more user context headers (roles, permissions, etc.)
2. **Header Signing**: Sign headers to prevent tampering
3. **Custom Claims**: Support custom claim mappings via configuration
4. **Header Encryption**: Encrypt sensitive user context data

### Configuration Options
```json
{
  "Authentication": {
    "UserContext": {
      "UserIdClaims": ["sub", "user_id", "userId"],
      "AdditionalHeaders": {
        "X-User-Email": "email",
        "X-User-Roles": "roles"
      },
      "SignHeaders": true,
      "EncryptHeaders": false
    }
  }
}
```