using SdxCore.Attendance.Application.DTOs.Time;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IScopeResolver
{
    Task<ScopeTypeResponse?> GetByCodeAsync(
        string scopeCode,
        CancellationToken cancellationToken = default);

    Task<Guid?> GetScopeTypeIdAsync(
        string scopeCode,
        CancellationToken cancellationToken = default);

    Task<ScopeTypeResponse> GetScopeTypeAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<ScopeTypeResponse>> GetAllAsync(
        CancellationToken cancellationToken = default);

    Task<string> GetScopeCodeByIdAsync(
        Guid scopeTypeId,
        CancellationToken cancellationToken = default);
}