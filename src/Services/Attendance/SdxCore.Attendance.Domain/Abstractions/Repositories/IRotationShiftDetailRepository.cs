using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IRotationShiftDetailRepository : IRepository<RotationShiftDetail, Guid>
{
    Task<IReadOnlyList<RotationShiftDetail>> GetByRotationShiftIdAsync(Guid rotationShiftId, CancellationToken cancellationToken = default);
}
