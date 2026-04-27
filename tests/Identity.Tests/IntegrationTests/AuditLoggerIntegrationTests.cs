using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Interfaces;
using Xunit;

namespace SdxCore.Identity.Tests.IntegrationTests;

/// <summary>
/// Integration tests for AuditLogger demonstrating end-to-end flow.
/// Uses mock repository to verify the complete async processing pipeline.
/// </summary>
public class AuditLoggerIntegrationTests : IDisposable
{
    private readonly Mock<IAuditRepository> _repositoryMock;
    private readonly AuditLogger _auditLogger;
    private readonly ILogger<AuditLogger> _logger;

    public AuditLoggerIntegrationTests()
    {
        _repositoryMock = new Mock<IAuditRepository>();
        
        // Create logger
        var loggerFactory = LoggerFactory.Create(builder => builder.AddConsole());
        _logger = loggerFactory.CreateLogger<AuditLogger>();
        
        _auditLogger = new AuditLogger(_repositoryMock.Object, _logger);
    }

    [Fact]
    public async Task LogAsync_WithValidEvent_PersistsToDatabase()
    {
        // Arrange
        var auditEvent = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            UserId = "user123",
            Username = "testuser",
            IpAddress = "192.168.1.1",
            OccurredAt = DateTimeOffset.UtcNow
        };

        // Act
        await _auditLogger.LogAsync(auditEvent);

        // Wait for background processing
        await Task.Delay(200);

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e => 
                e.EventType == "LOGIN_SUCCESS" && 
                e.Username == "testuser" &&
                e.IpAddress == "192.168.1.1" &&
                e.Protocol == AuthProtocol.InHouse),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task LogAsync_WithMultipleEvents_PersistsAllToDatabase()
    {
        // Arrange
        var events = new[]
        {
            new AuditEvent
            {
                EventType = "LOGIN_SUCCESS",
                Protocol = AuthProtocol.InHouse,
                Username = "user1",
                IpAddress = "192.168.1.1",
                OccurredAt = DateTimeOffset.UtcNow
            },
            new AuditEvent
            {
                EventType = "LOGIN_FAILURE",
                Protocol = AuthProtocol.Saml,
                Username = "user2",
                IpAddress = "192.168.1.2",
                OccurredAt = DateTimeOffset.UtcNow,
                FailureReason = "Invalid credentials"
            },
            new AuditEvent
            {
                EventType = "LOGIN_SUCCESS",
                Protocol = AuthProtocol.OAuth,
                Username = "user3",
                IpAddress = "192.168.1.3",
                OccurredAt = DateTimeOffset.UtcNow
            }
        };

        // Act
        foreach (var evt in events)
        {
            await _auditLogger.LogAsync(evt);
        }

        // Wait for background processing
        await Task.Delay(300);

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Exactly(3));
        
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e => e.Username == "user1"), It.IsAny<CancellationToken>()),
            Times.Once);
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e => e.Username == "user2"), It.IsAny<CancellationToken>()),
            Times.Once);
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e => e.Username == "user3"), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task LogAsync_WithFailureEvent_IncludesFailureReason()
    {
        // Arrange
        var auditEvent = new AuditEvent
        {
            EventType = "LOGIN_FAILURE",
            Protocol = AuthProtocol.InHouse,
            Username = "testuser",
            IpAddress = "192.168.1.1",
            OccurredAt = DateTimeOffset.UtcNow,
            FailureReason = "Invalid password"
        };

        // Act
        await _auditLogger.LogAsync(auditEvent);

        // Wait for background processing
        await Task.Delay(200);

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e => 
                e.EventType == "LOGIN_FAILURE" && 
                e.FailureReason == "Invalid password"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task Dispose_EnsuresAllPendingEventsArePersisted()
    {
        // Arrange
        var events = Enumerable.Range(1, 10).Select(i => new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = $"user{i}",
            IpAddress = "192.168.1.1",
            OccurredAt = DateTimeOffset.UtcNow
        }).ToArray();

        // Act
        foreach (var evt in events)
        {
            await _auditLogger.LogAsync(evt);
        }

        // Dispose immediately (should wait for all events to be processed)
        _auditLogger.Dispose();

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Exactly(10));
    }

    public void Dispose()
    {
        _auditLogger?.Dispose();
    }
}
