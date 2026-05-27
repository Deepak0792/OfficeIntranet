$appDir = "d:\Office\SdxCore\src\Services\Attendance\SdxCore.Attendance.Application"
$csprojPath = "$appDir\SdxCore.Attendance.Application.csproj"

$csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\SdxCore.Attendance.Domain\SdxCore.Attendance.Domain.csproj" />
    <ProjectReference Include="..\..\..\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Caching.Abstractions" Version="9.0.0" />
    <PackageReference Include="RabbitMQ.Client" Version="6.8.1" />
  </ItemGroup>
</Project>
"@
Set-Content -Path $csprojPath -Value $csprojContent

New-Item -ItemType Directory -Force -Path "$appDir\Services" | Out-Null
New-Item -ItemType Directory -Force -Path "$appDir\Interfaces" | Out-Null

$leaveReqCode = @"
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
"@
Set-Content -Path "$appDir\Services\LeaveRequestService.cs" -Value $leaveReqCode

$shiftServiceCode = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;

namespace SdxCore.Attendance.Application.Services;

public interface IShiftService
{
    Task<Shift?> GetShiftAsync(short shiftId, CancellationToken cancellationToken = default);
}

public class ShiftService : IShiftService
{
    private readonly AttendanceDbContext _dbContext;
    private readonly IDistributedCache _cache;
    private readonly string _cacheKeyPrefix = "shift:";

    public ShiftService(AttendanceDbContext dbContext, IDistributedCache cache)
    {
        _dbContext = dbContext;
        _cache = cache;
    }

    public async Task<Shift?> GetShiftAsync(short shiftId, CancellationToken cancellationToken = default)
    {
        string cacheKey = _cacheKeyPrefix + shiftId;
        var cachedData = await _cache.GetStringAsync(cacheKey, cancellationToken);
        if (!string.IsNullOrEmpty(cachedData))
        {
            return JsonSerializer.Deserialize<Shift>(cachedData);
        }

        var shift = await _dbContext.Shifts.FindAsync(new object[] { shiftId }, cancellationToken);
        if (shift != null)
        {
            var options = new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24) };
            await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(shift), options, cancellationToken);
        }

        return shift;
    }
}
"@
Set-Content -Path "$appDir\Services\ShiftService.cs" -Value $shiftServiceCode

Write-Output "Successfully generated Attendance Application Services."
