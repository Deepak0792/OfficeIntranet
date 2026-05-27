using SdxCore.Common.Extensions;
using SdxCore.Notification.Application.Extensions;
using SdxCore.Notification.Persistence.Extensions;
using SdxCore.Notification.API.BackgroundServices;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Common Layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Persistence & Application
builder.Services.AddNotificationPersistence(builder.Configuration);
builder.Services.AddNotificationServicesApplication();

// Background Consumers
builder.Services.AddHostedService<EcosystemEventConsumer>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
