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
