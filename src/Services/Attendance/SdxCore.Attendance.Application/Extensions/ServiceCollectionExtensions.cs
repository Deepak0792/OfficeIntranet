using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Abstractions.Scheduler;
using SdxCore.Attendance.Application.Abstractions.Services;
using SdxCore.Attendance.Application.BackgroundServices;
using SdxCore.Attendance.Application.Clients;
using SdxCore.Attendance.Application.Consumers;
using SdxCore.Attendance.Application.Resolvers;
using SdxCore.Attendance.Application.Services;
using SdxCore.Attendance.Application.Validators.Leave;
using SdxCore.Messaging.BackgroundServices;
using SdxCore.Messaging.Extensions;

namespace SdxCore.Attendance.Application.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSdxCoreAttendanceApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssemblyContaining<CreateLeaveRequestRequestValidator>();

        services.AddScoped<ILeaveTypeService, LeaveTypeService>();
        services.AddScoped<ILeaveService, LeaveService>();
        services.AddScoped<IShiftService, ShiftService>();
        services.AddScoped<IRosterService, RosterService>();
        services.AddScoped<IAttendanceService, AttendanceService>();
        services.AddScoped<IHolidayService, HolidayService>();
        services.AddScoped<IShiftSwapService, ShiftSwapService>();
        services.AddScoped<ICompOffService, CompOffService>();

        services.AddScoped<IEmployeeResolver, EmployeeResolver>();
        services.AddScoped<ILeaveTypeResolver, LeaveTypeResolver>();
        services.AddScoped<IShiftResolver, ShiftResolver>();
        services.AddScoped<IHolidayResolver, HolidayResolver>();
        services.AddScoped<IAttendanceResolver, AttendanceResolver>();
        services.AddScoped<IScopeResolver, ScopeResolver>();
        services.AddScoped<IHolidayCalendarResolver, HolidayCalendarResolver>();
        services.AddScoped<IHolidayTypeResolver, HolidayTypeResolver>();
        services.AddScoped<ICompOffTypeResolver, CompOffTypeResolver>();
        services.AddScoped<ILeaveBalanceResolver, LeaveBalanceResolver>();
        services.AddScoped<IWorkWeekPolicyResolver, WorkWeekPolicyResolver>();
        services.AddScoped<IEmployeeScopeResolver, EmployeeScopeResolver>();
        services.AddScoped<IRosterResolver, RosterResolver>();
        services.AddScoped<IShiftSwapResolver, ShiftSwapResolver>();
        services.AddScoped<IRegularizationResolver, RegularizationResolver>();
        services.AddScoped<ICompOffBalanceResolver, CompOffBalanceResolver>();
        services.AddScoped<IAttendanceStatusResolver, AttendanceStatusResolver>();
        services.AddScoped<IRosterGenerationScheduler, RosterGenerationScheduler>();
        services.AddScoped<IRosterGenerationPolicyResolver, RosterGenerationPolicyResolver>();
        services.AddScoped<IRosterGenerationService, RosterGenerationService>();
        services.AddScoped<ITimeZoneResolver, TimeZoneResolver>();

        services.AddHostedService<OutboxProcessorBackgroundService>();
        services.AddHostedService<RosterGenerationBackgroundService>();
        services.AddTransient<InternalApiKeyHandler>();

        return services;
    }

    public static IServiceCollection AddSdxCoreAttendanceMessaging(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        string serviceName = configuration["ServiceName"]?.ToLowerInvariant() ?? "attendance";

        services.AddSdxMessaging(
            configuration,
            endpointPrefix: serviceName,
            configureBus =>
            {
                configureBus.AddConsumer<EntityChangedEventConsumer>();
                configureBus.AddConsumer<WorkflowInstanceStatusChangedConsumer>();
            });

        return services;
    }

    public static IServiceCollection AddSdxCoreAttendanceHttpClients(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddHttpClient<IEmployeeClient, EmployeeClient>(client =>
        {
            var baseUrl = configuration["EmployeeClient:BaseUrl"] ?? string.Empty;
            client.BaseAddress = new Uri(baseUrl);
            client.Timeout = TimeSpan.FromSeconds(
                int.TryParse(configuration["EmployeeClient:TimeoutSeconds"], out var t) ? t : 10);
        }).AddHttpMessageHandler<InternalApiKeyHandler>();

        services.AddHttpClient<ITimeClient, TimeClient>(client =>
        {
            var baseUrl = configuration["TimeClient:BaseUrl"] ?? string.Empty;
            client.BaseAddress = new Uri(baseUrl);
            client.Timeout = TimeSpan.FromSeconds(
                int.TryParse(configuration["TimeClient:TimeoutSeconds"], out var t) ? t : 10);
        }).AddHttpMessageHandler<InternalApiKeyHandler>();

        return services;
    }
}
