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
