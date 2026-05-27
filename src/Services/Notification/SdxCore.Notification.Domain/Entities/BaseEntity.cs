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
