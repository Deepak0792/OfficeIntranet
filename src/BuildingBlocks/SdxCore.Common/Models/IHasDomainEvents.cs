using System.Collections.Generic;

namespace SdxCore.Common.Models;

public interface IHasDomainEvents
{
    IReadOnlyCollection<object> GetDomainEvents();
    void ClearDomainEvents();
}
