using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.LeaveType.Request;
using SdxCore.Attendance.Application.DTOs.LeaveType.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class LeaveTypeService(
    ILeaveTypeRepository repository,
    IAttendanceUnitOfWork unitOfWork,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : ILeaveTypeService
{
    private readonly ICacheService _cache = cacheService;
    private readonly ICacheKeyBuilder _keyBuilder = cacheKeyBuilder;

    public async Task<IEnumerable<LeaveTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(LeaveType), "all");
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var items = await repository.GetAllAsync(ct);
            return PropertyMapper.MapList<LeaveType, LeaveTypeResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? [];
    }

    public async Task<LeaveTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(LeaveType), id.ToString());
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var entity = await repository.GetByIdAsync(id, ct);
            return entity is null ? null : PropertyMapper.Map<LeaveType, LeaveTypeResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<LeaveTypeResponse> CreateAsync(CreateLeaveTypeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateLeaveTypeRequest, LeaveType>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<LeaveType, LeaveTypeResponse>(entity);
    }

    public async Task<LeaveTypeResponse?> UpdateAsync(Guid id, UpdateLeaveTypeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        PropertyMapper.Patch(request, entity);
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<LeaveType, LeaveTypeResponse>(entity);
    }

    public async Task<LeaveTypeResponse?> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        entity.IsActive = !entity.IsActive;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<LeaveType, LeaveTypeResponse>(entity);
    }
}
