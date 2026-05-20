using SdxCore.Identity.Application.Extensions;
using SdxCore.Shared.Application.Extensions;
using SdxCore.Shared.Persistence.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add controllers
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

// Register the persistence and application layers
builder.Services.AddSharedPersistence(builder.Configuration);
builder.Services.AddSharedApplication();

var app = builder.Build();

// Configure the HTTP request pipeline
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
