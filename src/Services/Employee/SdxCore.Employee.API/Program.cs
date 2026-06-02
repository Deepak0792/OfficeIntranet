using SdxCore.Common.Extensions;
using SdxCore.Employee.Application.Extensions;
using SdxCore.Employee.Persistence.Extensions;
using SdxCore.Caching.Extensions;
using SdxCore.Messaging.Extensions;
using SdxCore.SharedKernel.Extensions;

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

// Register Caching and Messaging
builder.Services.AddSdxCaching(builder.Configuration);
builder.Services.AddSdxMessaging(builder.Configuration);

// Register the persistence and application layers
builder.Services.AddEmployeePersistence(builder.Configuration);
builder.Services.AddEmployeeApplicationServices();

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

public partial class Program { }
