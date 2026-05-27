using System.Collections.Generic;

namespace SdxCore.Common.Messaging;

public interface IRabbitMqTopologyConfigurator
{
    void ConfigureTopology(string serviceName, IEnumerable<string> queueNames);
}
