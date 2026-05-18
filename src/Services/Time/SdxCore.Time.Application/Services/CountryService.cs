using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using System;
using SdxCore.Common.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class CountryService : ICountryService 
{
    private readonly ICountryRepository _repository;
    
    public CountryService(ICountryRepository repository) 
    {
        _repository = repository;
    }
    
        public async Task<PagedResponse<IEnumerable<CountryDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {
        var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var dtos = result.Items.Select(e => SimpleMapper.Map<Country, CountryDto>(e));
        return new PagedResponse<IEnumerable<CountryDto>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
    }

    public async Task<CountryDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<Country, CountryDto>(entity);
    }
    
    public async Task<CountryDto> CreateAsync(CreateCountryDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<CreateCountryDto, Country>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, UpdateCountryDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        SimpleMapper.MapProperties(dto, entity);
        
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
    
    public async Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.IsActive = false; // Soft delete
        _repository.Update(entity);
        await _repository.SaveChangesAsync(cancellationToken);
        return true;
    }
}

