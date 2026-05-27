using SdxCore.Common.Extensions;
using SdxCore.Workflow.Application.Extensions;
using SdxCore.Workflow.Persistence.Extensions;
using SdxCore.Workflow.API.BackgroundServices;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register the common layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Register Outbox & Quartz
builder.Services.AddSingleton<SdxCore.Common.Outbox.IEventPublisher, SdxCore.Common.Outbox.RabbitMqEventPublisher>();
builder.Services.AddHostedService<SdxCore.Common.Outbox.OutboxProcessorJob>();
builder.Services.AddSdxCoreQuartz(builder.Configuration);

// Register Consumers
builder.Services.AddHostedService<WorkflowInitiationConsumer>();

// Register the persistence and application layers
builder.Services.AddWorkflowPersistence(builder.Configuration);
builder.Services.AddWorkflowServicesApplication();

var app = builder.Build();

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

public partial class Program { }
