using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ICountryService
{
    Task<IEnumerable<CountryResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<CountryResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<CountryResponse> CreateAsync(CreateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateCountryRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


