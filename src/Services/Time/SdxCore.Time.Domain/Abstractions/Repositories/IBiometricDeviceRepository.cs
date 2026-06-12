using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Abstractions.Repositories;

public interface IBiometricDeviceRepository : IRepository<BiometricDevice, Guid> { }

