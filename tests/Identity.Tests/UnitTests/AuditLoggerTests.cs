using Microsoft.Extensions.Logging;
using Moq;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Application.Security;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Enums;
using SdxCore.Identity.Domain.Repositories;

namespace SdxCore.Identity.Tests.UnitTests;

public class AuditLoggerTests : IDisposable
{
    private readonly Mock<IAuditRepository> _repositoryMock;
    private readonly Mock<ILogger<AuditLogger>> _loggerMock;
    private readonly AuditLogger _auditLogger;

    public AuditLoggerTests()
    {
        _repositoryMock = new Mock<IAuditRepository>();
        _loggerMock = new Mock<ILogger<AuditLogger>>();
        _auditLogger = new AuditLogger(_repositoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task LogAsync_WithValidEvent_CallsRepositoryInsertAsync()
    {
        // Arrange
        var auditEvent = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            UserId = "user123",
            Username = "testuser",
            IpAddress = "192.168.1.1",
            CreatedAt = DateTime.UtcNow
        };

        // Act
        await _auditLogger.LogAsync(auditEvent);

        // Wait for background processing (fire-and-forget pattern)
        await Task.Delay(100);

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.Is<AuditEvent>(e =>
                e.EventType == "LOGIN_SUCCESS" &&
                e.Username == "testuser"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task LogAsync_WithNullEvent_ThrowsArgumentNullException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() => _auditLogger.LogAsync(null!));
    }

    [Fact]
    public async Task LogAsync_WithMultipleEvents_ProcessesAllEvents()
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
                CreatedAt = DateTime.UtcNow
            },
            new AuditEvent
            {
                EventType = "LOGIN_FAILURE",
                Protocol = AuthProtocol.InHouse,
                Username = "user2",
                IpAddress = "192.168.1.2",
                CreatedAt = DateTime.UtcNow,
                FailureReason = "Invalid credentials"
            },
            new AuditEvent
            {
                EventType = "LOGIN_SUCCESS",
                Protocol = AuthProtocol.Saml,
                Username = "user3",
                IpAddress = "192.168.1.3",
                CreatedAt = DateTime.UtcNow
            }
        };

        // Act
        foreach (var evt in events)
        {
            await _auditLogger.LogAsync(evt);
        }

        // Wait for background processing
        await Task.Delay(200);

        // Assert
        _repositoryMock.Verify(
            r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Exactly(3));
    }

    [Fact]
    public async Task LogAsync_WhenRepositoryThrows_ContinuesProcessingOtherEvents()
    {
        // Arrange
        var event1 = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = "user1",
            IpAddress = "192.168.1.1",
            CreatedAt = DateTime.UtcNow
        };

        var event2 = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = "user2",
            IpAddress = "192.168.1.2",
            CreatedAt = DateTime.UtcNow
        };

        // Setup repository to throw on first call, succeed on second
        _repositoryMock
            .SetupSequence(r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("Database error"))
            .Returns(Task.CompletedTask);

        // Act
        await _auditLogger.LogAsync(event1);
        await _auditLogger.LogAsync(event2);

        // Wait for background processing
        await Task.Delay(200);

        // Assert - Both events should have been attempted
        _repositoryMock.Verify(
            r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Exactly(2));
    }

    [Fact]
    public async Task LogAsync_ReturnsImmediately_FireAndForgetPattern()
    {
        // Arrange
        var auditEvent = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = "testuser",
            IpAddress = "192.168.1.1",
            CreatedAt = DateTime.UtcNow
        };

        // Setup repository with delay to simulate slow database
        _repositoryMock
            .Setup(r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()))
            .Returns(async () =>
            {
                await Task.Delay(500);
            });

        // Act
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        await _auditLogger.LogAsync(auditEvent);
        stopwatch.Stop();

        // Assert - LogAsync should return immediately (< 100ms)
        Assert.True(stopwatch.ElapsedMilliseconds < 100,
            $"LogAsync took {stopwatch.ElapsedMilliseconds}ms, expected < 100ms for fire-and-forget");
    }

    [Fact]
    public async Task Dispose_WaitsForPendingEvents_BeforeShutdown()
    {
        // Arrange
        var auditEvent = new AuditEvent
        {
            EventType = "LOGIN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = "testuser",
            IpAddress = "192.168.1.1",
            CreatedAt = DateTime.UtcNow
        };

        // Act
        await _auditLogger.LogAsync(auditEvent);
        _auditLogger.Dispose();

        // Assert - Repository should have been called before disposal
        _repositoryMock.Verify(
            r => r.InsertAsync(It.IsAny<AuditEvent>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    public void Dispose()
    {
        GC.SuppressFinalize(this);
        _auditLogger?.Dispose();
    }
}
