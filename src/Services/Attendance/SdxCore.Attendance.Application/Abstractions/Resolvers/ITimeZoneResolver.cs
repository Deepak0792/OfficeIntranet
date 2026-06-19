using SdxCore.Attendance.Application.DTOs.Time.Response;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ITimeZoneResolver
{
    Task<IReadOnlyCollection<TimeZoneMasterResponse>> GetAllAsync(
        CancellationToken cancellationToken = default);

    Task<TimeZoneMasterResponse?> GetByCodeAsync(
        string timeZoneCode,
        CancellationToken cancellationToken = default);

    Task<Guid?> GetTimeZoneIdAsync(
        string timeZoneCode,
        CancellationToken cancellationToken = default);

    Task<TimeZoneMasterResponse> GetTimeZoneAsync(
        Guid timeZoneId,
        CancellationToken cancellationToken = default);

    Task<string> GetTimeZoneCodeByIdAsync(
        Guid timeZoneId,
        CancellationToken cancellationToken = default);
}