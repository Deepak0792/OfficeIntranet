using SdxCore.Caching.Extensions;
using SdxCore.Common.Extensions;
using SdxCore.SharedKernel.Extensions;
using SdxCore.Time.Application.Extensions;
using SdxCore.Time.Persistence.Extensions;
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// HttpContext Access (Required for RequestContext)
builder.Services.AddHttpContextAccessor();

// Add health checks
builder.Services.AddHealthChecks();

// Add OpenAPI/Swagger for development
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register the common layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Register the sharedkernel layer
builder.Services.AddSdxCoreSharedKernel(builder.Configuration);

// Register Caching
builder.Services.AddSdxCoreCaching(builder.Configuration);

// Register Messaging
builder.Services.AddSdxCoreTimeMessaging(builder.Configuration);

// Register the persistence and application layers
builder.Services.AddSdxCoreTimePersistence(builder.Configuration);
builder.Services.AddSdxCoreTimeApplication();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();

// Map health check endpoint
app.MapHealthChecks("/health");

app.MapControllers();

app.Run();


// Make Program class accessible for integration tests
public partial class Program { }










