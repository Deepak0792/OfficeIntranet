$procDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Processor"
New-Item -ItemType Directory -Force -Path "$procDir\Jobs" | Out-Null

$csprojPath = "$procDir\SdxCore.Attendance.Processor.csproj"
$csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk.Worker">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="9.0.0" />
    <PackageReference Include="Quartz.Extensions.DependencyInjection" Version="3.13.1" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\SdxCore.Attendance.Application\SdxCore.Attendance.Application.csproj" />
    <ProjectReference Include="..\SdxCore.Attendance.Persistence\SdxCore.Attendance.Persistence.csproj" />
    <ProjectReference Include="..\..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
  </ItemGroup>

</Project>
"@
Set-Content -Path $csprojPath -Value $csprojContent

$builderCode = @"
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Quartz;

namespace SdxCore.Attendance.Processor.Jobs;

public class WorkSessionBuilderJob : IJob
{
    private readonly ILogger<WorkSessionBuilderJob> _logger;

    public WorkSessionBuilderJob(ILogger<WorkSessionBuilderJob> logger)
    {
        _logger = logger;
    }

    public Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Running WorkSessionBuilderJob at {Time}", DateTimeOffset.Now);
        // Logic to build work sessions from attendance logs
        return Task.CompletedTask;
    }
}
"@
Set-Content -Path "$procDir\Jobs\WorkSessionBuilderJob.cs" -Value $builderCode

$finalizerCode = @"
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Quartz;

namespace SdxCore.Attendance.Processor.Jobs;

public class AttendanceFinalizerJob : IJob
{
    private readonly ILogger<AttendanceFinalizerJob> _logger;

    public AttendanceFinalizerJob(ILogger<AttendanceFinalizerJob> logger)
    {
        _logger = logger;
    }

    public Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Running AttendanceFinalizerJob at {Time}", DateTimeOffset.Now);
        // Logic to finalize attendance and calculate late/early/overtime
        return Task.CompletedTask;
    }
}
"@
Set-Content -Path "$procDir\Jobs\AttendanceFinalizerJob.cs" -Value $finalizerCode

$rosterCode = @"
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Quartz;

namespace SdxCore.Attendance.Processor.Jobs;

public class RosterGenerationJob : IJob
{
    private readonly ILogger<RosterGenerationJob> _logger;

    public RosterGenerationJob(ILogger<RosterGenerationJob> logger)
    {
        _logger = logger;
    }

    public Task Execute(IJobExecutionContext context)
    {
        _logger.LogInformation("Running RosterGenerationJob at {Time}", DateTimeOffset.Now);
        // Logic to generate rosters based on rotation shifts and holidays
        return Task.CompletedTask;
    }
}
"@
Set-Content -Path "$procDir\Jobs\RosterGenerationJob.cs" -Value $rosterCode

$programCode = @"
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
"@
Set-Content -Path "$procDir\Program.cs" -Value $programCode

Write-Output "Successfully generated Attendance Processor jobs."
