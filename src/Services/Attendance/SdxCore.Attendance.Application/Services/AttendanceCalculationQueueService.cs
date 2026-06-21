using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Services;

public class AttendanceCalculationQueueService(
    IAttendanceCalculationQueueRepository repository)
    : IAttendanceCalculationQueueService
{
    public async Task EnqueueAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        AttendanceCalculationReason reason,
        byte priority = 1,
        CancellationToken cancellationToken = default)
    {
        var queue =
            await repository.GetAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        if (queue is null)
        {
            queue = new AttendanceCalculationQueue
            {
                Id = Guid.NewGuid(),
                EmployeeId = employeeId,
                AttendanceDate = attendanceDate,
                ReasonCode = (short)reason,
                Priority = priority,
                IsActive = true
            };

            await repository.AddAsync(
                queue,
                cancellationToken);
        }
        else
        {
            queue.ReasonCode = (short)reason;

            if (priority > queue.Priority)
            {
                queue.Priority = priority;
            }

            queue.ProcessedAt = null;

            repository.Update(queue);
        }
    }
}