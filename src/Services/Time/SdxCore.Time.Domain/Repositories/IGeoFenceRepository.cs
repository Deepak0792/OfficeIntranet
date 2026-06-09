using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Repositories;

public interface IGeoFenceRepository : IRepository<GeoFence, Guid> { }

