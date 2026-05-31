using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Messaging;

public interface IEventPublisher
{
    Task PublishAsync<T>(T @event, string routingKey, IDictionary<string, object>? headers = null, CancellationToken cancellationToken = default) where T : class;
    Task PublishRawAsync(string payload, string routingKey, IDictionary<string, object>? headers = null, CancellationToken cancellationToken = default);
}
