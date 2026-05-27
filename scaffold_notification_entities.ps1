$domainDir = "d:\Office\SdxCore\src\Services\Notification\SdxCore.Notification.Domain\Entities"
New-Item -ItemType Directory -Force -Path $domainDir | Out-Null

$baseEntityCode = @"
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using SdxCore.Common.Models;

namespace SdxCore.Notification.Domain.Entities;

public abstract class BaseEntity : IHasDomainEvents
{    
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public int? LastUpdatedBy { get; set; }

    private readonly List<object> _domainEvents = new();

    [NotMapped]
    public IReadOnlyCollection<object> DomainEvents => _domainEvents.AsReadOnly();

    public void AddDomainEvent(object domainEvent)
    {
        _domainEvents.Add(domainEvent);
    }

    public void RemoveDomainEvent(object domainEvent)
    {
        _domainEvents.Remove(domainEvent);
    }

    public void ClearDomainEvents()
    {
        _domainEvents.Clear();
    }

    public IReadOnlyCollection<object> GetDomainEvents() => _domainEvents.AsReadOnly();
}
"@
Set-Content -Path "$domainDir\BaseEntity.cs" -Value $baseEntityCode

$templateCode = @"
namespace SdxCore.Notification.Domain.Entities;

public class NotificationTemplate : BaseEntity
{
    public int Id { get; set; }
    public string EventName { get; set; } = string.Empty;
    public string Channel { get; set; } = "EMAIL"; // EMAIL, SMS, IN_APP
    public string SubjectTemplate { get; set; } = string.Empty;
    public string BodyTemplate { get; set; } = string.Empty;
}
"@
Set-Content -Path "$domainDir\NotificationTemplate.cs" -Value $templateCode

$logCode = @"
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
"@
Set-Content -Path "$domainDir\NotificationLog.cs" -Value $logCode

Write-Output "Successfully generated Notification Domain Entities."
