using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ICountryService
{
    Task<IEnumerable<CountryDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<CountryDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<CountryDto> CreateAsync(CreateCountryDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateCountryDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


