using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Attendance.Request;
using SdxCore.Attendance.Application.DTOs.Attendance.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;
using SdxCore.Common.Helpers;
using SdxCore.Common.Models;

namespace SdxCore.Attendance.Application.Services;

public class AttendanceService(
    IAttendanceLogRepository attendanceLogRepository,
    IAttendanceRecordRepository recordRepository,
    IAttendanceRegularizationRepository regularizationRepository,
    IAttendanceUnitOfWork unitOfWork) : IAttendanceService
{
    public async Task<AttendanceRecordResponse?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default)
    {
        var entity = await recordRepository.GetByEmployeeDateAsync(employeeId, date, cancellationToken);
        return entity is null ? null : MapResponse(entity);
    }

    public async Task<PagedResponse<IEnumerable<AttendanceRecordResponse>>> GetAllAsync(int page, int pageSize, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken cancellationToken = default)
    {
        var (items, total) = await recordRepository.GetPagedAsync(page, pageSize, employeeId, from, to, cancellationToken);
        return new PagedResponse<IEnumerable<AttendanceRecordResponse>>(items.Select(MapResponse), page, pageSize, total);
    }

    public async Task<AttendanceResponse> CheckInAsync(
        CheckInRequest request,
        CancellationToken cancellationToken = default)
    {
        var log = PropertyMapper.Map<CheckInRequest, AttendanceLog>(request);

        log.Id = Guid.NewGuid();
        log.PunchTime = request.CheckInTime;
        log.PunchType = AttendancePunchType.CheckIn;
        log.IsProcessed = false;
        log.IsActive = true;

        await attendanceLogRepository.AddAsync(
            log,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new AttendanceResponse
        {
            EmployeeId = request.EmployeeId,
            PunchTime = log.PunchTime,
            PunchType = log.PunchType,
            Message = "Check-in recorded successfully."
        };
    }

    public async Task<AttendanceResponse> CheckOutAsync(
        CheckOutRequest request,
        CancellationToken cancellationToken = default)
    {
        var log = PropertyMapper.Map<CheckOutRequest, AttendanceLog>(request);

        log.Id = Guid.NewGuid();
        log.PunchTime = request.CheckOutTime;
        log.PunchType = AttendancePunchType.CheckOut;
        log.IsProcessed = false;
        log.IsActive = true;

        await attendanceLogRepository.AddAsync(
            log,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new AttendanceResponse
        {
            EmployeeId = request.EmployeeId,
            PunchTime = log.PunchTime,
            PunchType = log.PunchType,
            Message = "Check-out recorded successfully."
        };
    }    

    public async Task<bool> LockAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await recordRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.AttendanceState = AttendanceState.Locked;
        recordRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<RegularizationResponse> SubmitRegularizationAsync(CreateRegularizationRequest request, CancellationToken cancellationToken = default)
    {
        var entity = PropertyMapper.Map<CreateRegularizationRequest, AttendanceRegularization>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        entity.RegularizationStatus = RegularizationStatus.Pending;

        await regularizationRepository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return MapRegResponse(entity);
    }

    public async Task<RegularizationResponse?> GetRegularizationByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await regularizationRepository.GetByIdAsync(id, cancellationToken);
        return entity is null ? null : MapRegResponse(entity);
    }

    public async Task<PagedResponse<IEnumerable<RegularizationResponse>>> GetRegularizationsAsync(int page, int pageSize, Guid? employeeId, CancellationToken cancellationToken = default)
    {
        var (items, total) = await regularizationRepository.GetPagedAsync(page, pageSize, employeeId, cancellationToken);
        return new PagedResponse<IEnumerable<RegularizationResponse>>(items.Select(MapRegResponse), page, pageSize, total);
    }

    public async Task UpdateRegularizationStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var entity = await regularizationRepository.GetByWorkflowInstanceIdAsync(workflowInstanceId, cancellationToken);
        if (entity is null) return; // idempotent
        entity.RegularizationStatus = newStatus;
        entity.Remarks = remarks;
        if (newStatus == RegularizationStatus.Approved) { entity.ApprovedBy = actionBy; entity.ApprovedAt = DateTime.UtcNow; }
        regularizationRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private static AttendanceRecordResponse MapResponse(AttendanceRecord r)
    {
        var response = PropertyMapper.Map<AttendanceRecord, AttendanceRecordResponse>(r);
        return response with
        {
            StatusCode = r.AttendanceStatus?.StatusCode,
            StatusName = r.AttendanceStatus?.StatusName
        };
    }

    private static RegularizationResponse MapRegResponse(AttendanceRegularization r) =>
        PropertyMapper.Map<AttendanceRegularization, RegularizationResponse>(r);
}
