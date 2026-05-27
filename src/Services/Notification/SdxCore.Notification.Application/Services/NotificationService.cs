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
