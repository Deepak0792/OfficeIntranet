using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Attendance.Domain.Abstractions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.Attendance.Persistence.Interceptors;
using SdxCore.Attendance.Persistence.Repositories;
using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Interceptors;

namespace SdxCore.Attendance.Persistence.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreAttendancePersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddHttpContextAccessor();
        services.AddSingleton<AuditInterceptor>();
        services.AddSingleton<OutboxSaveChangesInterceptor>();
        services.AddSingleton<AttendanceWorkflowOutboxInterceptor>();

        services.AddDbContext<AttendanceDbContext>((sp, options) =>
        {
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sql => sql.EnableRetryOnFailure(3, TimeSpan.FromSeconds(10), null));

            options.AddInterceptors(
                sp.GetRequiredService<AuditInterceptor>(),
                sp.GetRequiredService<OutboxSaveChangesInterceptor>(),
                sp.GetRequiredService<AttendanceWorkflowOutboxInterceptor>());
        });

        services.AddScoped<IAttendanceUnitOfWork, AttendanceUnitOfWork>();
        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<IAttendanceUnitOfWork>());

        // Repositories
        services.AddScoped<IAttendanceStatusRepository, AttendanceStatusRepository>();
        services.AddScoped<IShiftRepository, ShiftRepository>();
        services.AddScoped<IShiftAssignmentRepository, ShiftAssignmentRepository>();
        services.AddScoped<IRotationShiftRepository, RotationShiftRepository>();
        services.AddScoped<IRotationShiftDetailRepository, RotationShiftDetailRepository>();
        services.AddScoped<IRotationShiftAssignmentRepository, RotationShiftAssignmentRepository>();
        services.AddScoped<IEmployeeShiftRosterRepository, EmployeeShiftRosterRepository>();
        services.AddScoped<IEmployeeRosterGenerationTrackerRepository, EmployeeRosterGenerationTrackerRepository>();
        services.AddScoped<IWorkSessionRepository, WorkSessionRepository>();
        services.AddScoped<IAttendanceRecordRepository, AttendanceRecordRepository>();
        services.AddScoped<IAttendanceLogRepository, AttendanceLogRepository>();
        services.AddScoped<IMobileAttendanceLogRepository, MobileAttendanceLogRepository>();
        services.AddScoped<ILeaveTypeRepository, LeaveTypeRepository>();
        services.AddScoped<ILeaveRequestRepository, LeaveRequestRepository>();
        services.AddScoped<ILeaveBalanceRepository, LeaveBalanceRepository>();
        services.AddScoped<ICompOffTypeRepository, CompOffTypeRepository>();
        services.AddScoped<ICompOffBalanceRepository, CompOffBalanceRepository>();
        services.AddScoped<IAttendanceRegularizationRepository, AttendanceRegularizationRepository>();
        services.AddScoped<IHolidayCalendarRepository, HolidayCalendarRepository>();
        services.AddScoped<IHolidayTypeRepository, HolidayTypeRepository>();
        services.AddScoped<IHolidayRepository, HolidayRepository>();
        services.AddScoped<IHolidayCalendarAssignmentRepository, HolidayCalendarAssignmentRepository>();
        services.AddScoped<IWorkWeekPolicyRepository, WorkWeekPolicyRepository>();
        services.AddScoped<IWorkWeekPolicyDayRepository, WorkWeekPolicyDayRepository>();
        services.AddScoped<IWorkWeekPolicyAssignmentRepository, WorkWeekPolicyAssignmentRepository>();
        services.AddScoped<IShiftSwapRequestRepository, ShiftSwapRequestRepository>();
        services.AddScoped<IRosterGenerationPolicyRepository, RosterGenerationPolicyRepository>();
        services.AddScoped<IRosterGenerationPolicyAssignmentRepository, RosterGenerationPolicyAssignmentRepository>();
        services.AddScoped<ICompOffAvailmentRepository, CompOffAvailmentRepository>();
        services.AddScoped<IOutboxRepository, OutboxRepository>();

        return services;
    }
}
