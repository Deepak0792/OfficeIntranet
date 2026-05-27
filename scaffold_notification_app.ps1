$appDir = "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.Application"
$apiDir = "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.API"

New-Item -ItemType Directory -Force -Path "$appDir\Interfaces" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Services" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Providers" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Extensions" | Out-Null
New-Item -ItemType Directory -Force -Path "$apiDir\BackgroundServices" | Out-Null
New-Item -ItemType Directory -Force -Path "$apiDir\Controllers" | Out-Null
New-Item -ItemType Directory -Force -Path "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.Persistence\Extensions" | Out-Null

$csprojAppContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\SdxCore.Notification.Domain\SdxCore.Notification.Domain.csproj" />
    <ProjectReference Include="..\..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
  </ItemGroup>
</Project>
"@
Set-Content -Path "$appDir\SdxCore.Notification.Application.csproj" -Value $csprojAppContent

$csprojApiContent = @"
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="9.0.1" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="7.0.0" />
    <PackageReference Include="RabbitMQ.Client" Version="6.8.1" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\SdxCore.Notification.Application\SdxCore.Notification.Application.csproj" />
    <ProjectReference Include="..\SdxCore.Notification.Persistence\SdxCore.Notification.Persistence.csproj" />
    <ProjectReference Include="..\..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
  </ItemGroup>
</Project>
"@
Set-Content -Path "$apiDir\SdxCore.Notification.API.csproj" -Value $csprojApiContent

$providersCode = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SdxCore.Notification.Application.Providers;

public interface IEmailProvider
{
    Task SendEmailAsync(string to, string subject, string body, CancellationToken cancellationToken = default);
}

public interface ISmsProvider
{
    Task SendSmsAsync(string to, string message, CancellationToken cancellationToken = default);
}

public class DummyEmailProvider : IEmailProvider
{
    private readonly ILogger<DummyEmailProvider> _logger;

    public DummyEmailProvider(ILogger<DummyEmailProvider> logger)
    {
        _logger = logger;
    }

    public Task SendEmailAsync(string to, string subject, string body, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Sending EMAIL to {To}: {Subject}", to, subject);
        return Task.CompletedTask;
    }
}

public class DummySmsProvider : ISmsProvider
{
    private readonly ILogger<DummySmsProvider> _logger;

    public DummySmsProvider(ILogger<DummySmsProvider> logger)
    {
        _logger = logger;
    }

    public Task SendSmsAsync(string to, string message, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Sending SMS to {To}: {Message}", to, message);
        return Task.CompletedTask;
    }
}
"@
Set-Content -Path "$appDir\Providers\Providers.cs" -Value $providersCode

$notificationServiceCode = @"
using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SdxCore.Notification.Domain.Entities;
using SdxCore.Notification.Persistence.Data;
using SdxCore.Notification.Application.Providers;

namespace SdxCore.Notification.Application.Services;

public interface INotificationService
{
    Task ProcessEventAsync(string eventName, string payload, CancellationToken cancellationToken = default);
}

public class NotificationService : INotificationService
{
    private readonly NotificationDbContext _dbContext;
    private readonly IEmailProvider _emailProvider;
    private readonly ISmsProvider _smsProvider;

    public NotificationService(NotificationDbContext dbContext, IEmailProvider emailProvider, ISmsProvider smsProvider)
    {
        _dbContext = dbContext;
        _emailProvider = emailProvider;
        _smsProvider = smsProvider;
    }

    public async Task ProcessEventAsync(string eventName, string payload, CancellationToken cancellationToken = default)
    {
        var templates = await _dbContext.NotificationTemplates.ToListAsync(cancellationToken);
        
        foreach(var template in templates)
        {
            if(template.EventName.Equals(eventName, StringComparison.OrdinalIgnoreCase))
            {
                // In a real app, parse payload to get recipient and interpolate template variables
                var log = new NotificationLog
                {
                    NotificationTemplateId = template.Id,
                    RecipientEmployeeId = 1, // dummy
                    RecipientAddress = "user@example.com",
                    Channel = template.Channel,
                    Subject = template.SubjectTemplate,
                    Body = template.BodyTemplate,
                    Status = "SENT",
                    SentAt = DateTime.UtcNow
                };

                _dbContext.NotificationLogs.Add(log);

                if (template.Channel == "EMAIL")
                {
                    await _emailProvider.SendEmailAsync(log.RecipientAddress, log.Subject, log.Body, cancellationToken);
                }
                else if (template.Channel == "SMS")
                {
                    await _smsProvider.SendSmsAsync(log.RecipientAddress, log.Body, cancellationToken);
                }

                await _dbContext.SaveChangesAsync(cancellationToken);
            }
        }
    }
}
"@
Set-Content -Path "$appDir\Services\NotificationService.cs" -Value $notificationServiceCode

$appExt = @"
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Notification.Application.Providers;
using SdxCore.Notification.Application.Services;

namespace SdxCore.Notification.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddNotificationServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<IEmailProvider, DummyEmailProvider>();
        services.AddScoped<ISmsProvider, DummySmsProvider>();
        services.AddScoped<INotificationService, NotificationService>();
        return services;
    }
}
"@
Set-Content -Path "$appDir\Extensions\ServiceCollectionExtensions.cs" -Value $appExt

$persistenceExt = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Notification.Persistence.Data;

namespace SdxCore.Notification.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddNotificationPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<NotificationDbContext>(options =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
        });

        return services;
    }
}
"@
Set-Content -Path "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.Persistence\Extensions\ServiceCollectionExtensions.cs" -Value $persistenceExt

$consumerCode = @"
using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SdxCore.Notification.Application.Services;

namespace SdxCore.Notification.API.BackgroundServices;

public class EcosystemEventConsumer : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<EcosystemEventConsumer> _logger;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly string _queueName = "notification_ecosystem_events_queue";

    public EcosystemEventConsumer(IServiceProvider serviceProvider, IConfiguration configuration, ILogger<EcosystemEventConsumer> logger)
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
        
        // Bind to all events
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "#");
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
                var routingKey = ea.RoutingKey;
                
                using var scope = _serviceProvider.CreateScope();
                var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

                _logger.LogInformation("Notification Consumer received event: {RoutingKey}", routingKey);

                await notificationService.ProcessEventAsync(routingKey, message, stoppingToken);

                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing event for notifications");
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
Set-Content -Path "$apiDir\BackgroundServices\EcosystemEventConsumer.cs" -Value $consumerCode

$controllerCode = @"
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace SdxCore.Notification.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ConfigController : ControllerBase
{
    [HttpGet("templates")]
    public IActionResult GetTemplates()
    {
        return Ok(new { message = "Templates OK" });
    }
}
"@
Set-Content -Path "$apiDir\Controllers\ConfigController.cs" -Value $controllerCode

$programCode = @"
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
"@
Set-Content -Path "$apiDir\Program.cs" -Value $programCode

Write-Output "Successfully generated Notification Application and API."
