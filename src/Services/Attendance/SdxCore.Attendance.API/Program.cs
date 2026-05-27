using SdxCore.Common.Extensions;
using SdxCore.Attendance.Application.Extensions;
using SdxCore.Attendance.Persistence.Extensions;
using SdxCore.Attendance.API.BackgroundServices;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Common Layer
builder.Services.AddSdxCoreCommon(builder.Configuration);

// Outbox & Quartz
builder.Services.AddSingleton<SdxCore.Common.Outbox.IEventPublisher, SdxCore.Common.Outbox.RabbitMqEventPublisher>();
builder.Services.AddHostedService<SdxCore.Common.Outbox.OutboxProcessorJob>();
builder.Services.AddSdxCoreQuartz(builder.Configuration);

// Persistence & Application
builder.Services.AddAttendancePersistence(builder.Configuration);
builder.Services.AddAttendanceServicesApplication();

// Background Consumers
builder.Services.AddHostedService<WorkflowStatusConsumer>();
// Add Redis Caching
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
    options.InstanceName = "AttendanceCache_";
});

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
