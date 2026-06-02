using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface ICountryService
{
    Task<IEnumerable<CountryResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<CountryResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<CountryResponse> CreateAsync(CreateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


