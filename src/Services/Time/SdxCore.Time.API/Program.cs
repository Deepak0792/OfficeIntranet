using SdxCore.Common.Extensions;
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

// Register Caching
builder.Services.AddSdxCoreCaching(builder.Configuration);

// Register Outbox & Quartz
builder.Services.AddSingleton<SdxCore.Common.Outbox.IEventPublisher, SdxCore.Common.Outbox.RabbitMqEventPublisher>();
builder.Services.AddHostedService<SdxCore.Common.Outbox.OutboxProcessorJob>();
builder.Services.AddSdxCoreQuartz(builder.Configuration);

// Register Consumers
builder.Services.AddHostedService<SdxCore.Time.API.BackgroundServices.CacheInvalidationConsumer>();

// Register the persistence and application layers
builder.Services.AddTimePersistence(builder.Configuration);
builder.Services.AddTimeServicesApplication();

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
