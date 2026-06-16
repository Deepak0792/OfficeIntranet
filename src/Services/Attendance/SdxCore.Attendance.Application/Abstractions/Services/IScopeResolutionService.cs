using SdxCore.Attendance.Application.DTOs.Employee;
using SdxCore.Attendance.Application.DTOs.Time;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Services;

/// <summary>
/// Resolves scope-based configuration for a given employee on a given date.
/// Walks the scope chain from EMPLOYEE → TEAM → DEPARTMENT → OFFICE → LEGAL_ENTITY → COUNTRY → GLOBAL.
/// </summary>
public interface IScopeResolutionService
{
    /// <summary>Resolves the applicable Shift for the employee on date. Returns null if no assignment found.</summary>
    Task<Shift?> ResolveShiftAsync(EmployeeSummaryResponse employee, DateOnly date, IEnumerable<ScopeTypeResponse> scopeTypes, CancellationToken cancellationToken = default);

    /// <summary>Resolves all applicable holidays for the employee on a date range.</summary>
    Task<IEnumerable<Holiday>> ResolveHolidaysAsync(EmployeeSummaryResponse employee, DateOnly from, DateOnly to, IEnumerable<ScopeTypeResponse> scopeTypes, CancellationToken cancellationToken = default);

    /// <summary>Resolves the applicable WorkWeekPolicy for the employee on date.</summary>
    Task<WorkWeekPolicy?> ResolveWorkWeekPolicyAsync(EmployeeSummaryResponse employee, DateOnly date, IEnumerable<ScopeTypeResponse> scopeTypes, CancellationToken cancellationToken = default);

    /// <summary>Resolves the RotationShiftAssignment and computes the active shift on date.</summary>
    Task<Shift?> ResolveRotationShiftAsync(EmployeeSummaryResponse employee, DateOnly date, IEnumerable<ScopeTypeResponse> scopeTypes, CancellationToken cancellationToken = default);
}
