using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Outbox;

public interface IEventPublisher
{
    Task PublishAsync(string exchange, string routingKey, string payload, CancellationToken cancellationToken = default);
}
