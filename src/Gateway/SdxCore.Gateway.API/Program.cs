var builder = WebApplication.CreateBuilder(args);

// Add health checks
builder.Services.AddHealthChecks();

// Add YARP reverse proxy
builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

// Map health check endpoint
app.MapHealthChecks("/health");

// Map reverse proxy routes
app.MapReverseProxy();

app.Run();
