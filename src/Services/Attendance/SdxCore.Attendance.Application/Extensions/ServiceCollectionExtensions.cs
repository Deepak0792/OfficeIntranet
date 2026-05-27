using Microsoft.Extensions.DependencyInjection;
using SdxCore.Attendance.Application.Services;

namespace SdxCore.Attendance.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAttendanceServicesApplication(this IServiceCollection services)
    {
        services.AddScoped<ILeaveRequestService, LeaveRequestService>();
        services.AddScoped<IShiftService, ShiftService>();
        return services;
    }
}
