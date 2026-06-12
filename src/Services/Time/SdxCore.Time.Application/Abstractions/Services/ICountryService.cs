using SdxCore.Time.Application.DTOs.Country.Request;
using SdxCore.Time.Application.DTOs.Country.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface ICountryService
{
    Task<IEnumerable<CountryResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<CountryResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<CountryResponse> CreateAsync(CreateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


