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
    IAttendanceCalculationQueueService queueService,
    IAttendanceRecordRepository recordRepository,
    IWorkSessionRepository sessionRepository,
    IAttendanceRegularizationRepository regularizationRepository,
    IAttendanceStatusRepository statusRepository,
    IEmployeeShiftRosterRepository rosterRepository,
    ILeaveRequestRepository leaveRequestRepository,
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

    public async Task<AttendanceRecordResponse?> CheckInAsync(
    CheckInRequest request,
    CancellationToken cancellationToken = default)
    {
        var attendanceDate =
            DateOnly.FromDateTime(request.CheckInTime);

        var roster =
            await rosterRepository.GetByEmployeeDateAsync(
                request.EmployeeId,
                attendanceDate,
                cancellationToken);

        var session =
            await sessionRepository.GetByEmployeeDateAsync(
                request.EmployeeId,
                attendanceDate,
                cancellationToken);

        if (session is null)
        {
            session = PropertyMapper.Map<
                CheckInRequest,
                WorkSession>(request);

            session.Id = Guid.NewGuid();
            session.EmployeeShiftRosterId = roster?.Id;
            session.SessionDate = attendanceDate;
            session.IsActive = true;

            await sessionRepository.AddAsync(
                session,
                cancellationToken);
        }
        else
        {
            session.CheckInTime = request.CheckInTime;

            sessionRepository.Update(session);
        }

        await queueService.EnqueueAsync(
            request.EmployeeId,
            attendanceDate,
            AttendanceCalculationReason.PunchReceived,
            priority: 5,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(
            cancellationToken);

        return null;
    }

    public async Task<AttendanceRecordResponse?> CheckOutAsync(
    CheckOutRequest request,
    CancellationToken cancellationToken = default)
    {
        var attendanceDate =
            DateOnly.FromDateTime(request.CheckOutTime);

        var session =
            await sessionRepository.GetByEmployeeDateAsync(
                request.EmployeeId,
                attendanceDate,
                cancellationToken)
            ?? throw new InvalidOperationException("Check-in not found.");

        session.CheckOutTime = request.CheckOutTime;

        if (session.CheckInTime != default)
        {
            session.WorkedMinutes =
                (int)(request.CheckOutTime -
                      session.CheckInTime)
                .TotalMinutes;
        }

        sessionRepository.Update(session);

        await queueService.EnqueueAsync(
            request.EmployeeId,
            attendanceDate,
            AttendanceCalculationReason.PunchReceived,
            priority: 5,
            cancellationToken);

        await unitOfWork.SaveChangesAsync(
            cancellationToken);

        return null;
    }

    public async Task ProcessDailyAsync(DateOnly date, CancellationToken cancellationToken = default)
    {
        var rosters = await rosterRepository.GetByDateAsync(date, cancellationToken);
        var presentStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.Present, cancellationToken);
        var absentStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.Absent, cancellationToken);
        var leaveStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.OnLeave, cancellationToken);
        var holidayStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.Holiday, cancellationToken);
        var weekendStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.Weekend, cancellationToken);
        var lateStatusId = await statusRepository.GetIdByCodeAsync(AttendanceStatusCodes.Late, cancellationToken);

        foreach (var roster in rosters)
        {
            var session = await sessionRepository.GetByRosterAsync(roster.Id, cancellationToken);
            var approvedLeave = await leaveRequestRepository.GetApprovedLeaveForDateAsync(roster.EmployeeId, date, cancellationToken);

            Guid? statusId;
            bool isOnLeave = false, isHoliday = roster.IsHoliday, isWeeklyOff = roster.IsOffDay;
            short? workedMinutes = (short?)session?.WorkedMinutes;

            if (roster.IsHoliday) statusId = holidayStatusId;
            else if (roster.IsOffDay) statusId = weekendStatusId;
            else if (approvedLeave is not null) { statusId = leaveStatusId; isOnLeave = true; }
            else if (session is null) statusId = absentStatusId;
            else if (roster.Shift is not null && session.CheckInTime != default
                     && session.CheckInTime.TimeOfDay > roster.Shift.StartTime.ToTimeSpan().Add(TimeSpan.FromMinutes(roster.Shift.GraceInMinutes)))
                statusId = lateStatusId;
            else statusId = presentStatusId;

            var record = new AttendanceRecord
            {
                Id = Guid.NewGuid(),
                EmployeeId = roster.EmployeeId,
                AttendanceDate = date,
                EmployeeShiftRosterId = roster.Id,
                WorkSessionId = session?.Id,
                ShiftId = roster.ShiftId,
                AttendanceStatusId = statusId,
                CheckInTime = session?.CheckInTime,
                CheckOutTime = session?.CheckOutTime,
                WorkedMinutes = workedMinutes,
                IsOnLeave = isOnLeave,
                IsHoliday = isHoliday,
                IsWeeklyOff = isWeeklyOff,
                IsAutoProcessed = true,
                IsActive = true
            };
            await recordRepository.UpsertAsync(record, cancellationToken);
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> LockAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await recordRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsAttendanceLocked = true;
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
