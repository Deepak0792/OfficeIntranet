// SdxCore.SharedKernel.Persistence
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.SharedKernel.Contracts;

namespace SdxCore.SharedKernel.Persistence;

public sealed class AuditInterceptor : SaveChangesInterceptor
{
    private readonly IServiceProvider _serviceProvider;

    public AuditInterceptor(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        if (eventData.Context is not null)
            ApplyAuditFields(eventData.Context);

        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    private void ApplyAuditFields(DbContext context)
    {
        var userContext = _serviceProvider
            .GetRequiredService<IHttpContextAccessor>()
            .HttpContext?
            .RequestServices
            .GetService<IUserContext>();

        var userId = userContext?.UserId;
        var now = DateTime.UtcNow;

        foreach (var entry in context.ChangeTracker.Entries())
        {
            if (entry.State == EntityState.Added)
            {
                TrySet(entry, "CreatedAt", now);
                TrySetIfNull(entry, "CreatedBy", userId);
                TrySet(entry, "LastUpdatedAt", now);
                TrySetIfNull(entry, "LastUpdatedBy", userId);
            }
            else if (entry.State == EntityState.Modified)
            {
                TrySet(entry, "LastUpdatedAt", now);
                TrySetIfNull(entry, "LastUpdatedBy", userId);
            }
        }
    }

    private static void TrySet(EntityEntry entry, string propertyName, object? value)
    {
        var prop = entry.Properties.FirstOrDefault(p => p.Metadata.Name == propertyName);
        if (prop is not null)
            prop.CurrentValue = value;
    }

    private static void TrySetIfNull(EntityEntry entry, string propertyName, object? value)
    {
        var prop = entry.Properties.FirstOrDefault(p => p.Metadata.Name == propertyName);
        if (prop is not null && prop.CurrentValue is null)
            prop.CurrentValue = value;
    }
}