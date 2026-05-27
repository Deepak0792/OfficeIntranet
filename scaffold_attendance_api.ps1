$apiDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.API"
$appDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Application\Extensions"
$persistenceDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Persistence\Extensions"

New-Item -ItemType Directory -Force -Path "$apiDir\BackgroundServices" | Out-Null
New-Item -ItemType Directory -Force -Path "$apiDir\Controllers" | Out-Null
New-Item -ItemType Directory -Force -Path $appDir | Out-Null
New-Item -ItemType Directory -Force -Path $persistenceDir | Out-Null

$appExt = @"
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Attendance.Application.Services;

namespace SdxCore.Attendance.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAttendanceServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<ILeaveRequestService, LeaveRequestService>();
        services.AddScoped<IShiftService, ShiftService>();
        return services;
    }
}
"@
Set-Content -Path "$appDir\ServiceCollectionExtensions.cs" -Value $appExt

$persistenceExt = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Common.Outbox;
using SdxCore.Attendance.Persistence.Data;
using System.Text.Json;

namespace SdxCore.Attendance.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAttendancePersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<OutboxSaveChangesInterceptor>();
        
        services.AddDbContext<AttendanceDbContext>((sp, options) =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            options.AddInterceptors(sp.GetRequiredService<OutboxSaveChangesInterceptor>());
        });
        
        services.AddScoped<IOutboxRepository>(sp => 
        {
            var dbContext = sp.GetRequiredService<AttendanceDbContext>();
            return new OutboxRepository(dbContext, JsonSerializerOptions.Default);
        });

        return services;
    }
}
"@
Set-Content -Path "$persistenceDir\ServiceCollectionExtensions.cs" -Value $persistenceExt

$consumerCode = @"
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SdxCore.Attendance.Persistence.Data;

namespace SdxCore.Attendance.API.BackgroundServices;

public class WorkflowStatusConsumer : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<WorkflowStatusConsumer> _logger;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly string _queueName = "attendance_workflow_status_queue";

    public WorkflowStatusConsumer(IServiceProvider serviceProvider, IConfiguration configuration, ILogger<WorkflowStatusConsumer> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;

        var factory = new ConnectionFactory
        {
            Uri = new Uri(configuration.GetConnectionString("RabbitMQ") ?? "amqp://guest:guest@localhost:5672"),
            DispatchConsumersAsync = true
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();

        var exchangeName = "sdxcore-events";
        _channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Topic, durable: true);

        // Durable queue
        _channel.QueueDeclare(queue: _queueName, durable: true, exclusive: false, autoDelete: false);
        
        // Bind to workflow status changed event
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "*.workflow.status_changed");
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                
                using var scope = _serviceProvider.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<AttendanceDbContext>();

                var doc = JsonDocument.Parse(message);
                var root = doc.RootElement;
                
                var workflowInstanceId = root.GetProperty("WorkflowInstanceId").GetInt32();
                var newStatus = root.GetProperty("NewStatus").GetString();

                _logger.LogInformation("Processing Workflow Status Change for Instance {WorkflowInstanceId} to {Status}", workflowInstanceId, newStatus);

                // For example, if it's a LEAVE_REQUEST workflow, find LeaveRequest and update status
                // var leaveRequest = await dbContext.LeaveRequests.FirstOrDefaultAsync(l => l.WorkflowInstanceId == workflowInstanceId, stoppingToken);
                // if(leaveRequest != null) { leaveRequest.LeaveStatus = newStatus; await dbContext.SaveChangesAsync(); }

                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing workflow status change");
                _channel.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(queue: _queueName, autoAck: false, consumer: consumer);

        return Task.CompletedTask;
    }

    public override void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
        base.Dispose();
    }
}
"@
Set-Content -Path "$apiDir\BackgroundServices\WorkflowStatusConsumer.cs" -Value $consumerCode

$programCode = @"
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
"@
Set-Content -Path "$apiDir\Program.cs" -Value $programCode

$controllerCode = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SdxCore.Attendance.Application.Services;

namespace SdxCore.Attendance.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LeaveController : ControllerBase
{
    private readonly ILeaveRequestService _leaveService;

    public LeaveController(ILeaveRequestService leaveService)
    {
        _leaveService = leaveService;
    }

    [HttpPost]
    public async Task<IActionResult> SubmitLeaveRequest([FromBody] LeaveRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _leaveService.SubmitLeaveRequestAsync(
            request.EmployeeId, 
            request.LeaveTypeId, 
            request.FromDate, 
            request.ToDate, 
            request.Reason, 
            cancellationToken);
            
        return Ok(result);
    }
}

public class LeaveRequestDto
{
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public System.DateTime FromDate { get; set; }
    public System.DateTime ToDate { get; set; }
    public string Reason { get; set; } = string.Empty;
}
"@
Set-Content -Path "$apiDir\Controllers\LeaveController.cs" -Value $controllerCode

Write-Output "Successfully generated Attendance API."
