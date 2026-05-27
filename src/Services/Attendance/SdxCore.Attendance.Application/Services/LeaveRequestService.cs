using System;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Events;
using SdxCore.Common.Outbox;

namespace SdxCore.Attendance.Application.Services;

public interface ILeaveRequestService
{
    Task<LeaveRequest> SubmitLeaveRequestAsync(int employeeId, short leaveTypeId, DateTime fromDate, DateTime toDate, string reason, CancellationToken cancellationToken = default);
}

public class LeaveRequestService : ILeaveRequestService
{
    private readonly SdxCore.Attendance.Persistence.Data.AttendanceDbContext _dbContext;

    public LeaveRequestService(SdxCore.Attendance.Persistence.Data.AttendanceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<LeaveRequest> SubmitLeaveRequestAsync(int employeeId, short leaveTypeId, DateTime fromDate, DateTime toDate, string reason, CancellationToken cancellationToken = default)
    {
        var totalDays = (decimal)(toDate - fromDate).TotalDays + 1;
        
        var request = new LeaveRequest
        {
            EmployeeId = employeeId,
            LeaveTypeId = leaveTypeId,
            LeaveStatus = "PENDING",
            FromDate = fromDate,
            ToDate = toDate,
            TotalDays = totalDays,
            Reason = reason
        };

        // Emit domain event which will be intercepted by Outbox
        request.AddDomainEvent(new WorkflowInitiatedEvent
        {
            ModuleName = "LEAVE_REQUEST",
            EntityId = request.Id,
            InitiatorEmployeeId = employeeId
        });

        _dbContext.LeaveRequests.Add(request);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return request;
    }
}
