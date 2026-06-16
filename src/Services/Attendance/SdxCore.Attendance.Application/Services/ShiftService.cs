using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Shift.Request;
using SdxCore.Attendance.Application.DTOs.Shift.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class ShiftService(
    IShiftRepository repository,
    IAttendanceUnitOfWork unitOfWork,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : IShiftService
{
    private readonly ICacheService _cache = cacheService;
    private readonly ICacheKeyBuilder _keyBuilder = cacheKeyBuilder;

    public async Task<IEnumerable<ShiftResponse>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(Shift), "all");
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var items = await repository.GetAllAsync(ct);
            return PropertyMapper.MapList<Shift, ShiftResponse>(items);
        }, CacheOptions.StaticMasterData, cancellationToken) ?? [];
    }

    public async Task<ShiftResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var key = _keyBuilder.BuildKey(nameof(Shift), id.ToString());
        return await _cache.GetOrSetAsync(key, async ct =>
        {
            var entity = await repository.GetByIdAsync(id, ct);
            return entity is null ? null : PropertyMapper.Map<Shift, ShiftResponse>(entity);
        }, CacheOptions.StaticMasterData, cancellationToken);
    }

    public async Task<ShiftResponse> CreateAsync(CreateShiftRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateShiftRequest, Shift>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;

        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Shift, ShiftResponse>(entity);
    }

    public async Task<ShiftResponse?> UpdateAsync(Guid id, UpdateShiftRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        PropertyMapper.Patch(request, entity);
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Shift, ShiftResponse>(entity);
    }

    public async Task<ShiftResponse?> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return null;

        entity.IsActive = !entity.IsActive;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return PropertyMapper.Map<Shift, ShiftResponse>(entity);
    }
}
