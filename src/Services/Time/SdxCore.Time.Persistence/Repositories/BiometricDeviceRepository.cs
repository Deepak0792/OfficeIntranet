using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class BiometricDeviceRepository
    : BaseRepository<BiometricDevice, Guid, TimeDbContext>, IBiometricDeviceRepository
{
    public BiometricDeviceRepository(TimeDbContext dbContext)
        : base(dbContext) { }
}