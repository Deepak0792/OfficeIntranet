using SdxCore.Caching.Extensions;
using SdxCore.Common.Extensions;
using SdxCore.SharedKernel.Extensions;
using SdxCore.Workflow.Application.Extensions;
using SdxCore.Workflow.Persistence.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register the common layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Register the sharedkernel layer
builder.Services.AddSdxCoreSharedKernel(builder.Configuration);

// Register Caching
builder.Services.AddSdxCoreCaching(builder.Configuration);

// Register Messaging
builder.Services.AddSdxCoreWorkflowMessaging(builder.Configuration);

// Register the persistence and application layers
builder.Services.AddSdxCoreWorkflowPersistence(builder.Configuration);
builder.Services.AddSdxCoreWorkflowApplication();

var app = builder.Build();

// Use Global Exception Middleware
app.UseGlobalExceptionHandling();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapHealthChecks("/health");
app.MapControllers();

app.Run();

// Make Program class accessible for integration tests
public partial class Program { }
