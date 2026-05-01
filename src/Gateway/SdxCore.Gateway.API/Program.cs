using SdxCore.Gateway.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add health checks
builder.Services.AddHealthChecks();

// Add HTTP client factory for calling downstream services
builder.Services.AddHttpClient();

// Configure HTTP client for Identity service
builder.Services.AddHttpClient("IdentityService", client =>
{
    var identityServiceUrl = builder.Configuration["Authentication:IdentityServiceUrl"];
    if (!string.IsNullOrWhiteSpace(identityServiceUrl))
    {
        client.BaseAddress = new Uri(identityServiceUrl);
    }
    client.Timeout = TimeSpan.FromSeconds(30); // 30 second timeout for token validation
});

// Add YARP reverse proxy
builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseHttpsRedirection();

// Add authentication middleware before reverse proxy
// This will validate tokens for protected routes
app.UseGatewayAuthentication();

// Map health check endpoint
app.MapHealthChecks("/health");

// Map reverse proxy routes
app.MapReverseProxy();

app.Run();
