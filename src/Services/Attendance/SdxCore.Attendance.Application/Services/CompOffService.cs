using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.DTOs.CompOff.Request;
using SdxCore.Attendance.Application.DTOs.CompOff.Response;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Services;

public class CompOffService(
    ICompOffBalanceRepository repository,
    ICompOffTypeRepository compOffTypeRepository,
    IAttendanceUnitOfWork unitOfWork) : ICompOffService
{
    public async Task<CompOffBalanceResponse> EarnAsync(EarnCompOffRequest request, CancellationToken cancellationToken = default)
    {
        var compOffType = await compOffTypeRepository.GetByIdAsync(request.CompOffTypeId, cancellationToken)
            ?? throw new InvalidOperationException($"CompOffType {request.CompOffTypeId} not found.");

        var entity = PropertyMapper.Map<EarnCompOffRequest, CompOffBalance>(request);
        entity.Id = Guid.NewGuid();
        entity.IsActive = true;
        entity.AvailedDays = 0;
        entity.ExpiryDate = compOffType.ExpiryDays.HasValue
            ? request.EarnedDate.AddDays(compOffType.ExpiryDays.Value)
            : null;

        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        var response = PropertyMapper.Map<CompOffBalance, CompOffBalanceResponse>(entity);
        return response with { CompOffTypeName = compOffType.CompOffTypeName };
    }

    public async Task<CompOffBalanceResponse> RedeemAsync(RedeemCompOffRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByIdAsync(request.CompOffBalanceId, cancellationToken)
            ?? throw new InvalidOperationException($"CompOffBalance {request.CompOffBalanceId} not found.");

        if (entity.EmployeeId != request.EmployeeId)
            throw new InvalidOperationException("CompOffBalance does not belong to this employee.");

        if (entity.RemainingDays < request.RequestedDays)
            throw new InvalidOperationException("Insufficient comp-off balance.");

        entity.AvailedDays += request.RequestedDays;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        var redeemResponse = PropertyMapper.Map<CompOffBalance, CompOffBalanceResponse>(entity);
        return redeemResponse with { CompOffTypeName = entity.CompOffType?.CompOffTypeName ?? string.Empty };
    }

    public async Task<IEnumerable<CompOffBalanceResponse>> GetBalanceAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        var items = await repository.GetByEmployeeAsync(employeeId, cancellationToken);
        return items.Select(x =>
        {
            var r = PropertyMapper.Map<CompOffBalance, CompOffBalanceResponse>(x);
            return r with { CompOffTypeName = x.CompOffType?.CompOffTypeName ?? string.Empty };
        });
    }

    public async Task UpdateStatusFromWorkflowAsync(Guid workflowInstanceId, string newStatus, Guid actionBy, string? remarks, CancellationToken cancellationToken = default)
    {
        var entity = await repository.GetByWorkflowInstanceIdAsync(workflowInstanceId, cancellationToken);
        if (entity is null) return;
        repository.Update(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

}
