using SdxCore.Common.Interfaces.Data;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IBiometricMappingRepository : IRepository<BiometricEmployeeMapping, int>
{
}
