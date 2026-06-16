using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Request;
using SdxCore.Attendance.Application.DTOs.ShiftSwap.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Enums.Attendance;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class ShiftSwapService(
    IShiftSwapRequestRepository repository,
    IAttendanceUnitOfWork unitOfWork,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : IShiftSwapService
{
    private readonly ICacheService _cache = cacheService;
    private readonly ICacheKeyBuilder _keyBuilder = cacheKeyBuilder;

    public async Task<ShiftSwapResponse> RequestSwapAsync(CreateShiftSwapRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateShiftSwapRequest, ShiftSwapRequest>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        entity.ShiftSwapStatus = ShiftSwapStatus.Pending;
        entity.RequestedAt = DateTime.UtcNow;

        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<ShiftSwapRequest, ShiftSwapResponse>(entity);
    }

    public async Task<ShiftSwapResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(ShiftSwapRequest), id.ToString());
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        return entity is null ? null : PropertyMapper.Map<ShiftSwapRequest, ShiftSwapResponse>(entity);
        //}, CacheOptions.Default, cancellationToken);
    }

    public async Task<IEnumerable<ShiftSwapResponse>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(ShiftSwapRequest), $"emp_{employeeId}");
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var items = await repository.GetByEmployeeAsync(employeeId, cancellationToken);
        return PropertyMapper.MapList<ShiftSwapRequest, ShiftSwapResponse>(items);
        //}, CacheOptions.Default, cancellationToken) ?? [];
    }

    public async Task<bool> CancelAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.ShiftSwapStatus = ShiftSwapStatus.Cancelled;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByWorkflowInstanceIdAsync(workflowInstanceId, cancellationToken);
        if (entity is null) return;
        entity.ShiftSwapStatus = newStatus;
        entity.Remarks = remarks;
        if (newStatus == ShiftSwapStatus.Approved) { entity.ApprovedBy = actionBy; entity.ApprovedAt = DateTime.UtcNow; }
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }
}
