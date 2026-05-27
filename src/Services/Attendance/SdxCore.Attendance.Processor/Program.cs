using SdxCore.Common.Extensions;
using SdxCore.Attendance.Persistence.Extensions;
using SdxCore.Attendance.Application.Extensions;
using SdxCore.Attendance.Processor.Jobs;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Quartz;

var builder = Host.CreateDefaultBuilder(args);

builder.ConfigureServices((context, services) =>
{
    var configuration = context.Configuration;

    // Common Layer
    services.AddSdxCoreCommon(configuration);

    // Persistence & Application
    services.AddAttendancePersistence(configuration);
    services.AddAttendanceServicesApplication();

    // Outbox & Quartz
    services.AddSingleton<SdxCore.Common.Outbox.IEventPublisher, SdxCore.Common.Outbox.RabbitMqEventPublisher>();
    services.AddHostedService<SdxCore.Common.Outbox.OutboxProcessorJob>();
    services.AddSdxCoreQuartz(configuration);

    services.AddQuartz(q =>
    {
        q.UseMicrosoftDependencyInjectionJobFactory();

        var wsJobKey = new JobKey("WorkSessionBuilderJob");
        q.AddJob<WorkSessionBuilderJob>(opts => opts.WithIdentity(wsJobKey));
        q.AddTrigger(opts => opts
            .ForJob(wsJobKey)
            .WithIdentity("WorkSessionBuilderJob-trigger")
            .WithCronSchedule("0 * * ? * *")); // Every minute for testing

        var afJobKey = new JobKey("AttendanceFinalizerJob");
        q.AddJob<AttendanceFinalizerJob>(opts => opts.WithIdentity(afJobKey));
        q.AddTrigger(opts => opts
            .ForJob(afJobKey)
            .WithIdentity("AttendanceFinalizerJob-trigger")
            .WithCronSchedule("0 0 1 * * ?")); // Nightly at 1 AM

        var rgJobKey = new JobKey("RosterGenerationJob");
        q.AddJob<RosterGenerationJob>(opts => opts.WithIdentity(rgJobKey));
        q.AddTrigger(opts => opts
            .ForJob(rgJobKey)
            .WithIdentity("RosterGenerationJob-trigger")
            .WithCronSchedule("0 0 2 25 * ?")); // 25th of every month at 2 AM
    });

    services.AddQuartzHostedService(q => q.WaitForJobsToComplete = true);
});

var host = builder.Build();
host.Run();
