using System;
using System.ComponentModel.DataAnnotations;

namespace SdxCore.SharedKernel.Entities;

public class OutboxMessage
{
    [Key]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(500)]
    public string EventType { get; set; } = null!;

    [Required]
    public string Payload { get; set; } = null!;

    [Required]
    [MaxLength(200)]
    public string Exchange { get; set; } = null!;

    [Required]
    [MaxLength(200)]
    public string RoutingKey { get; set; } = null!;

    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "PENDING";

    [Required]
    [MaxLength(50)]
    public string StatusGroup { get; set; } = "OUTBOX_STATUS";

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Guid? CreatedBy { get; set; }

    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;

    public Guid? LastUpdatedBy { get; set; }

    public DateTime? PublishedAt { get; set; }

    public int RetryCount { get; set; } = 0;

    public string? ErrorMessage { get; set; }
}
