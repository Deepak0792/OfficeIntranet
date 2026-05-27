using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SdxCore.Common.Outbox;

public class OutboxMessage
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(500)]
    public string EventType { get; set; } = string.Empty;
    
    [Required]
    public string Payload { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string Exchange { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string RoutingKey { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "PENDING";
    
    [Required]
    [MaxLength(50)]
    public string StatusGroup { get; set; } = "OUTBOX_STATUS";
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
    
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;
    public int? LastUpdatedBy { get; set; }
    
    public DateTime? PublishedAt { get; set; }
    
    public int RetryCount { get; set; } = 0;
    
    public string? ErrorMessage { get; set; }
}
