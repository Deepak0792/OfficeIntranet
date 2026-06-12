namespace SdxCore.Messaging.Abstractions;

public interface IEventPublisher
{
    Task PublishAsync<T>(
              T @event,
              IDictionary<string, object>? headers = null,
              CancellationToken cancellationToken = default)
              where T : class;

    Task PublishAsync(
         object @event,
         IDictionary<string, object>? headers = null,
         CancellationToken cancellationToken = default);

    Task PublishRawAsync(
          string payload,
          string messageType,
          IDictionary<string, object>? headers = null,
          CancellationToken cancellationToken = default);
}
