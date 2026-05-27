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
using SdxCore.Workflow.Domain.Interfaces.Services;

namespace SdxCore.Workflow.API.BackgroundServices;

public class WorkflowInitiationConsumer : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<WorkflowInitiationConsumer> _logger;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly string _queueName = "workflow_initiation_queue";

    public WorkflowInitiationConsumer(IServiceProvider serviceProvider, IConfiguration configuration, ILogger<WorkflowInitiationConsumer> logger)
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

        // Durable queue for workflows (survives restarts)
        _channel.QueueDeclare(queue: _queueName, durable: true, exclusive: false, autoDelete: false);
        
        // Bind to all workflow initiation events (e.g. employee.employeeaddress.workflow_initiated)
        _channel.QueueBind(queue: _queueName, exchange: exchangeName, routingKey: "*.workflow_initiated");
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
                var resolutionService = scope.ServiceProvider.GetRequiredService<IWorkflowResolutionService>();

                // Parse the generic event structure
                // Expecting WorkflowInitiatedEvent structure
                var doc = JsonDocument.Parse(message);
                var root = doc.RootElement;
                
                var moduleName = root.GetProperty("ModuleName").GetString() ?? string.Empty;
                var entityId = root.GetProperty("EntityId").GetInt32();
                var initiatorEmployeeId = root.GetProperty("InitiatorEmployeeId").GetInt32();

                _logger.LogInformation("Processing Workflow Initiation for Module {Module} with Entity {EntityId}", moduleName, entityId);

                await resolutionService.InitiateWorkflowAsync(moduleName, entityId, initiatorEmployeeId, stoppingToken);

                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing workflow initiation message");
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
