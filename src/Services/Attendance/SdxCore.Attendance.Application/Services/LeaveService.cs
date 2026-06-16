using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Leave.Request;
using SdxCore.Attendance.Application.DTOs.Leave.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Enums.Attendance;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;

namespace SdxCore.Attendance.Application.Services;

public class LeaveService(
    ILeaveRequestRepository leaveRequestRepository,
    ILeaveTypeRepository leaveTypeRepository,
    ILeaveBalanceRepository leaveBalanceRepository,
    IAttendanceUnitOfWork unitOfWork,
    ICacheService cacheService,
    ICacheKeyBuilder cacheKeyBuilder) : ILeaveService
{
    private readonly ICacheService _cache = cacheService;
    private readonly ICacheKeyBuilder _keyBuilder = cacheKeyBuilder;

    public async Task<LeaveRequestResponse> SubmitAsync(CreateLeaveRequestRequest request, CancellationToken cancellationToken = default)
    {
        var leaveType = await leaveTypeRepository.GetByIdAsync(request.LeaveTypeId, cancellationToken)
            ?? throw new InvalidOperationException($"LeaveType {request.LeaveTypeId} not found.");

        var entity = PropertyMapper.Map<CreateLeaveRequestRequest, LeaveRequest>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        entity.LeaveStatus = LeaveStatus.Pending;
        entity.LeaveType = leaveType;

        await leaveRequestRepository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return BuildResponse(entity, leaveType.LeaveName);
    }

    public async Task<LeaveRequestResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(LeaveRequest), id.ToString());
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var entity = await leaveRequestRepository.GetByIdAsync(id, cancellationToken);
        return entity is null ? null : BuildResponse(entity, entity.LeaveType?.LeaveName ?? string.Empty);
        //}, CacheOptions.Default, cancellationToken);
    }

    public async Task<PagedResponse<IEnumerable<LeaveRequestResponse>>> GetAllAsync(int page, int pageSize, Guid? employeeId, string? status, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(LeaveRequest), $"paged_{page}_{pageSize}_{employeeId}_{status}");
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var (items, total) = await leaveRequestRepository.GetPagedAsync(page, pageSize, employeeId, status, cancellationToken);
        var responses = items.Select(x => BuildResponse(x, x.LeaveType?.LeaveName ?? string.Empty));
        return new PagedResponse<IEnumerable<LeaveRequestResponse>>(responses, page, pageSize, total);
        //}, CacheOptions.Default, cancellationToken)
        //    ?? new PagedResponse<IEnumerable<LeaveRequestResponse>>([], page, pageSize, 0);
    }

    public async Task<IEnumerable<LeaveRequestResponse>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(LeaveRequest), $"emp_{employeeId}");
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var items = await leaveRequestRepository.GetByEmployeeAsync(employeeId, cancellationToken);
        return items.Select(x => BuildResponse(x, x.LeaveType?.LeaveName ?? string.Empty));
        //}, CacheOptions.Default, cancellationToken) ?? [];
    }

    public async Task<bool> CancelAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await leaveRequestRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.LeaveStatus = LeaveStatus.Cancelled;
        leaveRequestRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> WithdrawAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await leaveRequestRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.LeaveStatus = LeaveStatus.Withdrawn;
        leaveRequestRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var entity = await leaveRequestRepository.GetByWorkflowInstanceIdAsync(workflowInstanceId, cancellationToken);
        if (entity is null) return;

        entity.LeaveStatus = newStatus;
        entity.Remarks = remarks;
        if (newStatus == LeaveStatus.Approved) { entity.ApprovedBy = actionBy; entity.ApprovedAt = DateTime.UtcNow; }

        leaveRequestRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    public async Task<IEnumerable<LeaveBalanceResponse>> GetBalanceAsync(Guid employeeId, int year, CancellationToken cancellationToken = default)
    {
        //var key = _keyBuilder.BuildKey(nameof(LeaveBalance), $"emp_{employeeId}_{year}");
        //return await _cache.GetOrSetAsync(key, async ct =>
        //{
        var balances = await leaveBalanceRepository.GetByEmployeeAsync(employeeId, year, cancellationToken);
        return PropertyMapper.MapList<LeaveBalance, LeaveBalanceResponse>(balances);
        //}, CacheOptions.Default, cancellationToken) ?? [];
    }

    private static LeaveRequestResponse BuildResponse(LeaveRequest entity, string leaveTypeName) =>
        new(entity.Id, entity.EmployeeId, entity.LeaveTypeId, leaveTypeName, entity.LeaveStatus,
            entity.FromDate, entity.ToDate, entity.TotalDays, entity.IsHalfDay, entity.HalfDaySession,
            entity.Reason, entity.WorkflowInstanceId, entity.Remarks, entity.ApprovedBy, entity.ApprovedAt,
            entity.CreatedAt);
}
