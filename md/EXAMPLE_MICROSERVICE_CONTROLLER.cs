// Example: How to use X-User-Id header in downstream microservices
// This shows how your microservices can access the user context provided by the Gateway

using Microsoft.AspNetCore.Mvc;

namespace YourMicroservice.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetUserOrders()
    {
        // Extract user ID from the X-User-Id header added by the Gateway
        var userId = Request.Headers["X-User-Id"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(userId))
        {
            _logger.LogWarning("X-User-Id header is missing from request");
            return BadRequest(new { Error = "User context not available" });
        }

        _logger.LogInformation("Getting orders for user: {UserId}", userId);

        try
        {
            // Use the user ID for business logic
            var orders = await _orderService.GetOrdersByUserIdAsync(userId);
            return Ok(orders);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting orders for user: {UserId}", userId);
            return StatusCode(500, new { Error = "Internal server error" });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        // Extract user ID from header
        var userId = Request.Headers["X-User-Id"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(userId))
        {
            return BadRequest(new { Error = "User context not available" });
        }

        _logger.LogInformation("Creating order for user: {UserId}", userId);

        try
        {
            // Create order with user context
            var order = await _orderService.CreateOrderAsync(userId, request);
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order for user: {UserId}", userId);
            return StatusCode(500, new { Error = "Internal server error" });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrder(int id)
    {
        var userId = Request.Headers["X-User-Id"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(userId))
        {
            return BadRequest(new { Error = "User context not available" });
        }

        try
        {
            // Get order and verify it belongs to the user
            var order = await _orderService.GetOrderByIdAsync(id);
            
            if (order == null)
            {
                return NotFound();
            }

            // Ensure user can only access their own orders
            if (order.UserId != userId)
            {
                _logger.LogWarning("User {UserId} attempted to access order {OrderId} belonging to user {OrderUserId}", 
                    userId, id, order.UserId);
                return Forbid();
            }

            return Ok(order);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting order {OrderId} for user: {UserId}", id, userId);
            return StatusCode(500, new { Error = "Internal server error" });
        }
    }
}

// Alternative approach: Create a base controller that automatically extracts user context
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

// Usage with base controller
[ApiController]
[Route("api/[controller]")]
public class ProfileController : AuthenticatedControllerBase
{
    private readonly IUserService _userService;

    public ProfileController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userId = GetRequiredUserId(); // Throws if not available
            var profile = await _userService.GetUserProfileAsync(userId);
            return Ok(profile);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}

// Middleware approach: Extract user context into HttpContext.Items
public class UserContextMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<UserContextMiddleware> _logger;

    public UserContextMiddleware(RequestDelegate next, ILogger<UserContextMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Extract user ID from header and store in HttpContext.Items
        var userId = context.Request.Headers["X-User-Id"].FirstOrDefault();
        
        if (!string.IsNullOrEmpty(userId))
        {
            context.Items["UserId"] = userId;
            _logger.LogDebug("User context set: {UserId}", userId);
        }

        await _next(context);
    }
}

// Extension method for middleware registration
public static class UserContextMiddlewareExtensions
{
    public static IApplicationBuilder UseUserContext(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<UserContextMiddleware>();
    }
}

// Service to access user context
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

// Usage in Program.cs of your microservice
/*
var builder = WebApplication.CreateBuilder(args);

// Register services
builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();

var app = builder.Build();

// Add user context middleware
app.UseUserContext();

app.UseRouting();
app.MapControllers();

app.Run();
*/