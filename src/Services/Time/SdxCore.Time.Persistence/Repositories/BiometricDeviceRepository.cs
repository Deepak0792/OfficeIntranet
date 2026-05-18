using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class BiometricDeviceRepository : BaseRepository<BiometricDevice>, IBiometricDeviceRepository
{
    public BiometricDeviceRepository(TimeDbContext dbContext) : base(dbContext) { }
}
