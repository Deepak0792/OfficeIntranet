using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.Roster.Request;
using SdxCore.Attendance.Application.DTOs.Roster.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class RosterService(
    IEmployeeShiftRosterRepository rosterRepository,
    IAttendanceUnitOfWork unitOfWork) : IRosterService
{
    public async Task<IEnumerable<RosterResponse>> GetByEmployeeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default)
    {
        var items = await rosterRepository.GetByEmployeeRangeAsync(employeeId, from, to, cancellationToken);
        return items.Select(MapResponse);
    }

    public async Task<IEnumerable<RosterResponse>> GetByDateAsync(DateOnly date, CancellationToken cancellationToken = default)
    {
        var items = await rosterRepository.GetByDateAsync(date, cancellationToken);
        return items.Select(MapResponse);
    }

    public async Task<RosterGenerationResult> GenerateAsync(GenerateRosterRequest request, CancellationToken cancellationToken = default)
    {
        var result = new RosterGenerationResult(0, 0, 0, []);
        var employeeIds = request.EmployeeIds?.ToList() ?? [];
        int created = 0, skipped = 0;

        for (var date = request.FromDate; date <= request.ToDate; date = date.AddDays(1))
        {
            foreach (var empId in employeeIds)
            {
                var existing = await rosterRepository.GetByEmployeeDateAsync(empId, date, cancellationToken);
                if (existing?.IsLocked == true && !request.ForceRegenerate) { skipped++; continue; }

                if (existing is null)
                {
                    var roster = new EmployeeShiftRoster
                    {
                        Id = Guid.NewGuid(),
                        EmployeeId = empId,
                        RosterDate = date,
                        IsLocked = request.LockAfterGenerate,
                        IsActive = true,
                        Remarks = request.Remarks
                    };
                    await rosterRepository.AddAsync(roster, cancellationToken);
                }
                else
                {
                    existing.IsLocked = request.LockAfterGenerate;
                    rosterRepository.Update(existing);
                }
                created++;
            }
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return result with { TotalEmployees = employeeIds.Count, TotalRows = created, Skipped = skipped };
    }

    public async Task<RosterUploadResult> UploadAsync(RosterUploadRequest request, CancellationToken cancellationToken = default)
    {
        int created = 0, updated = 0, skipped = 0;
        var errors = new List<string>();

        foreach (var row in request.Rows)
        {
            try
            {
                var existing = await rosterRepository.GetByEmployeeDateAsync(row.EmployeeId, row.Date, cancellationToken);
                if (existing is null)
                {
                    var roster = PropertyMapper.Map<RosterRowRequest, EmployeeShiftRoster>(row);
                    roster.Id = Guid.NewGuid();
                    roster.IsLocked = request.LockAfterUpload;
                    roster.IsActive = true;
                    await rosterRepository.AddAsync(roster, cancellationToken);
                    created++;
                }
                else if (!existing.IsLocked)
                {
                    existing.ShiftId = row.ShiftId;
                    existing.IsOffDay = row.IsOffDay;
                    existing.IsHoliday = row.IsHoliday;
                    existing.IsLocked = request.LockAfterUpload;
                    existing.Remarks = row.Remarks;
                    rosterRepository.Update(existing);
                    updated++;
                }
                else { skipped++; }
            }
            catch (Exception ex) { errors.Add($"Row {row.EmployeeId}/{row.Date}: {ex.Message}"); }
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return new RosterUploadResult(request.Rows.Count, created, updated, skipped, errors);
    }

    public async Task<bool> UpdateAsync(Guid id, UpdateRosterRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await rosterRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        PropertyMapper.Patch(request, entity);
        rosterRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> LockAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await rosterRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsLocked = true;
        rosterRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> UnlockAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await rosterRepository.GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsLocked = false;
        rosterRepository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task ExecuteShiftSwapAsync(Guid requesterRosterId, Guid targetRosterId, CancellationToken cancellationToken = default)
    {
        var requester = await rosterRepository.GetByIdAsync(requesterRosterId, cancellationToken)
            ?? throw new InvalidOperationException($"Roster {requesterRosterId} not found.");
        var target = await rosterRepository.GetByIdAsync(targetRosterId, cancellationToken)
            ?? throw new InvalidOperationException($"Roster {targetRosterId} not found.");

        (requester.ShiftId, target.ShiftId) = (target.ShiftId, requester.ShiftId);
        rosterRepository.Update(requester);
        rosterRepository.Update(target);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private static RosterResponse MapResponse(EmployeeShiftRoster r)
    {
        var response = PropertyMapper.Map<EmployeeShiftRoster, RosterResponse>(r);
        return response with { ShiftName = r.Shift?.ShiftName };
    }
}
