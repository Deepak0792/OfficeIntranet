using System;

namespace SdxCore.Notification.Domain.Entities;

public class NotificationLog : BaseEntity
{
    public long Id { get; set; }
    public int? NotificationTemplateId { get; set; }
    public int RecipientEmployeeId { get; set; }
    public string RecipientAddress { get; set; } = string.Empty;
    public string Channel { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Status { get; set; } = "PENDING";
    public DateTime? SentAt { get; set; }
    public string? ErrorMessage { get; set; }
    
    public NotificationTemplate? Template { get; set; }
}
