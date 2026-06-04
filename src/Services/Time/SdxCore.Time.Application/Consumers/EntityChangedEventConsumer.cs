using MassTransit;
using Microsoft.Extensions.Logging;
using SdxCore.Caching;
using SdxCore.SharedKernel.Events;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Application.Consumers;

/// <summary>
/// Consumes <see cref="EntityChangedEvent"/> messages published by the outbox
/// and invalidates relevant cache entries for the Time microservice.
/// </summary>
public sealed class EntityChangedEventConsumer : IConsumer<EntityChangedEvent>
{
    // Entities owned / cached by the Time microservice.
    private static readonly HashSet<string> _trackedEntities = new(StringComparer.OrdinalIgnoreCase)
    {
        nameof(Country),
        nameof(Department),
        nameof(Designation),
        nameof(DocumentType),
        nameof(GeoFence),
        nameof(LegalEntity),
        nameof(OfficeLocation),
        nameof(Region),
        nameof(ScopeType),
        nameof(TimeZoneMaster)
    };
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    private readonly ILogger<EntityChangedEventConsumer> _logger;

    public EntityChangedEventConsumer(
        ICacheService cacheService,
        ICacheKeyBuilder cacheKeyBuilder,
        ILogger<EntityChangedEventConsumer> logger)
    {
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<EntityChangedEvent> context)
    {
        var evt = context.Message;

        if (!_trackedEntities.Contains(evt.EntityName))
        {
            _logger.LogDebug(
                "Skipping cache invalidation for untracked entity '{EntityName}'.",
                evt.EntityName);
            return;
        }

        _logger.LogInformation(
            "Cache invalidation triggered. Entity={EntityName}, Id={EntityId}, Operation={Operation}",
            evt.EntityName,
            evt.Id,
            evt.Operation);

        try
        {
            // Invalidate the specific entity key: {env}:{entity}:{id}
            var exactKey = _cacheKeyBuilder.BuildKey(evt.EntityName, evt.Id);
            await _cacheService.RemoveAsync(exactKey, context.CancellationToken);

            // Invalidate any list/query keys that include this entity: {env}:{entity}:*
            var listPattern = _cacheKeyBuilder.BuildPattern(evt.EntityName, "*");
            await _cacheService.RemoveByPatternAsync(listPattern, context.CancellationToken);

            _logger.LogInformation(
                "Cache invalidated for Entity={EntityName}, Id={EntityId}.",
                evt.EntityName,
                evt.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to invalidate cache for Entity={EntityName}, Id={EntityId}.",
                evt.EntityName,
                evt.Id);

            // Re-throw so MassTransit's retry/fault pipeline handles it.
            throw;
        }
    }
}