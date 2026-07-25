using SdxCore.Attendance.Application.Abstractions.Processor;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.BackgroundServices.Processor;

public sealed class AttendanceLogProcessor(
    IAttendanceLogRepository attendanceLogRepository,
    ICheckInProcessor checkInProcessor,
    ICheckOutProcessor checkOutProcessor,
    IAttendanceUnitOfWork unitOfWork) : IAttendanceLogProcessor
{
    public async Task ProcessPendingLogsAsync(int batchSize,
        CancellationToken cancellationToken = default)
    {
        while (true)
        {
            var logs =
                await attendanceLogRepository.GetPendingLogsAsync(
                    batchSize,
                    cancellationToken);

            if (logs.Count == 0)
                break;

            foreach (var log in logs)
            {
                try
                {
                    if (log.PunchType == AttendancePunchType.CheckIn)
                    {
                        await checkInProcessor.ProcessAsync(
                            log,
                            cancellationToken);
                    }
                    else if (log.PunchType == AttendancePunchType.CheckOut)
                    {
                        await checkOutProcessor.ProcessAsync(
                            log,
                            cancellationToken);
                    }

                    log.IsProcessed = true;
                }
                catch (Exception ex)
                {
                    // Don't stop processing remaining logs.
                    // Persist the error for retry/diagnostics.
                    log.RetryCount++;
                    log.ErrorMessage = ex.Message;
                }
            }

            await unitOfWork.SaveChangesAsync(
                cancellationToken);
        }
    }
}