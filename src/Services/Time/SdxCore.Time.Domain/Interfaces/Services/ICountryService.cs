using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ICountryService
{
    Task<IEnumerable<CountryDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<CountryDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<CountryDto> CreateAsync(CreateCountryDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateCountryDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


