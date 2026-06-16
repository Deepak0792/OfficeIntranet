using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IRotationShiftRepository : IRepository<RotationShift, Guid>
{
    Task<RotationShift?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);
}
