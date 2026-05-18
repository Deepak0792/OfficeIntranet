$baseDir = "d:\Office\SdxCore\src"
$appDir = "$baseDir\Services\Time\SdxCore.Time.Application"
$domainDir = "$baseDir\Services\Time\SdxCore.Time.Domain"
$repoDir = "$baseDir\Services\Time\SdxCore.Time.Persistence\Repositories"
$apiDir = "$baseDir\Services\Time\SdxCore.Time.API"

function Write-File ($path, $content) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $path -Value $content.Trim() -Encoding UTF8
}

Write-Host "Creating SimpleMapper..."
Write-File "$appDir\Helpers\SimpleMapper.cs" @"
using System.Linq;

namespace SdxCore.Time.Application.Helpers;

public static class SimpleMapper 
{
    public static TDest Map<TSource, TDest>(TSource source) where TDest : new() 
    {
        if (source == null) return default;
        var dest = new TDest();
        MapProperties(source, dest);
        return dest;
    }

    public static void MapProperties<TSource, TDest>(TSource source, TDest dest) 
    {
        var sourceProps = typeof(TSource).GetProperties();
        var destProps = typeof(TDest).GetProperties();

        foreach (var sp in sourceProps) 
        {
            var dp = destProps.FirstOrDefault(x => x.Name == sp.Name && x.PropertyType == sp.PropertyType);
            if (dp != null && dp.CanWrite) 
            {
                dp.SetValue(dest, sp.GetValue(source));
            }
        }
    }
}
"@

$entities = @(
    @{ Name="TimeZoneMaster"; Plural="TimeZoneMasters"; Props="public required string TimeZoneCode { get; set; }`n    public required string TimeZoneName { get; set; }`n    public required string UtcOffset { get; set; }`n    public int OffsetMinutes { get; set; }`n    public bool SupportsDaylightSaving { get; set; }`n    public string? WindowsTimeZoneId { get; set; }`n    public string? IanaTimeZoneId { get; set; }`n    public string? CountryCode { get; set; }"; Route="time-zones" },
    @{ Name="Country"; Plural="Countries"; Props="public required string CountryCode { get; set; }`n    public required string CountryName { get; set; }`n    public string? CurrencyCode { get; set; }`n    public long? TimeZoneId { get; set; }"; Route="countries" },
    @{ Name="Region"; Plural="Regions"; Props="public long CountryId { get; set; }`n    public required string RegionName { get; set; }`n    public string? RegionType { get; set; }`n    public long? ParentRegionId { get; set; }"; Route="regions" },
    @{ Name="LegalEntity"; Plural="LegalEntities"; Props="public required string EntityCode { get; set; }`n    public required string EntityName { get; set; }`n    public long CountryId { get; set; }`n    public string? TaxIdentificationNumber { get; set; }`n    public string? RegistrationNumber { get; set; }`n    public string? CurrencyCode { get; set; }"; Route="legal-entities" },
    @{ Name="OfficeLocation"; Plural="OfficeLocations"; Props="public long LegalEntityId { get; set; }`n    public long CountryId { get; set; }`n    public long? RegionId { get; set; }`n    public required string LocationCode { get; set; }`n    public required string LocationName { get; set; }`n    public string? BuildingName { get; set; }`n    public string? AddressLine1 { get; set; }`n    public string? AddressLine2 { get; set; }`n    public string? City { get; set; }`n    public string? StateProvince { get; set; }`n    public string? PostalCode { get; set; }`n    public decimal? Latitude { get; set; }`n    public decimal? Longitude { get; set; }`n    public long? TimeZoneId { get; set; }`n    public bool IsHeadOffice { get; set; }"; Route="office-locations" },
    @{ Name="ScopeType"; Plural="ScopeTypes"; Props="public required string ScopeCode { get; set; }`n    public required string ScopeName { get; set; }`n    public int HierarchyLevel { get; set; }"; Route="scope-types" },
    @{ Name="Designation"; Plural="Designations"; Props="public required string DesignationCode { get; set; }`n    public required string DesignationName { get; set; }`n    public string? Grade { get; set; }"; Route="designations" },
    @{ Name="DocumentType"; Plural="DocumentTypes"; Props="public required string DocumentTypeCode { get; set; }`n    public required string DocumentTypeName { get; set; }`n    public string? Category { get; set; }`n    public string? Description { get; set; }`n    public bool IsMandatory { get; set; }"; Route="document-types" },
    @{ Name="GeoFence"; Plural="GeoFences"; Props="public required string GeoFenceCode { get; set; }`n    public required string GeoFenceName { get; set; }`n    public decimal Latitude { get; set; }`n    public decimal Longitude { get; set; }`n    public decimal RadiusMeters { get; set; }`n    public long? OfficeId { get; set; }"; Route="geo-fences" },
    @{ Name="BiometricDevice"; Plural="BiometricDevices"; Props="public required string DeviceCode { get; set; }`n    public required string DeviceName { get; set; }`n    public string? SerialNumber { get; set; }`n    public long? OfficeId { get; set; }`n    public string? IpAddress { get; set; }`n    public DateTime? LastSyncAt { get; set; }"; Route="biometric-devices" }
)

foreach ($e in $entities) {
    $name = $e.Name
    $plural = $e.Plural
    $props = $e.Props
    $route = $e.Route

    Write-Host "Generating $name..."

    # DTOs
    Write-File "$appDir\DTOs\${name}Dto.cs" @"
namespace SdxCore.Time.Application.DTOs;

public class ${name}Dto
{
    public long Id { get; set; }
    $props
    public bool IsActive { get; set; }
}

public class Create${name}Dto
{
    $props
}

public class Update${name}Dto : Create${name}Dto { }
"@

    # IRepo
    Write-File "$domainDir\Interfaces\I${name}Repository.cs" @"
using SdxCore.Common.Data;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Interfaces;

public interface I${name}Repository : IRepository<${name}> { }
"@

    # Repo
    Write-File "$repoDir\${name}Repository.cs" @"
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class ${name}Repository : BaseRepository<${name}>, I${name}Repository
{
    public ${name}Repository(TimeDbContext dbContext) : base(dbContext) { }
}
"@

    # IService
    Write-File "$appDir\Services\I${name}Service.cs" @"
using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface I${name}Service
{
    Task<IEnumerable<${name}Dto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<${name}Dto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<${name}Dto> CreateAsync(Create${name}Dto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, Update${name}Dto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}
"@

    # Service
    Write-File "$appDir\Services\${name}Service.cs" @"
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Helpers;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class ${name}Service : I${name}Service 
{
    private readonly I${name}Repository _repository;
    
    public ${name}Service(I${name}Repository repository) 
    {
        _repository = repository;
    }
    
    public async Task<IEnumerable<${name}Dto>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(e => SimpleMapper.Map<${name}, ${name}Dto>(e));
    }
    
    public async Task<${name}Dto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return null;
        return SimpleMapper.Map<${name}, ${name}Dto>(entity);
    }
    
    public async Task<${name}Dto> CreateAsync(Create${name}Dto dto, CancellationToken cancellationToken = default) 
    {
        var entity = SimpleMapper.Map<Create${name}Dto, ${name}>(dto);
        entity.IsActive = true;
        entity.CreatedAt = DateTime.UtcNow;
        
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, Update${name}Dto dto, CancellationToken cancellationToken = default) 
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
"@

    # Controller
    Write-File "$apiDir\Controllers\${plural}Controller.cs" @"
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using SdxCore.Common.Models;
using SdxCore.Common.Security;
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route(`"api/v1/$route`")]
[GatewayOnly]
public class ${plural}Controller : ControllerBase
{
    private readonly I${name}Service _service;
    private readonly ILogger<${plural}Controller> _logger;

    public ${plural}Controller(I${name}Service service, ILogger<${plural}Controller> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<${name}Dto>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<${name}Dto>>(result, `"Successfully fetched ${plural}.`"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while fetching all ${plural}`");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"FETCH_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpGet(`"{id}`")]
    [ProducesResponseType(typeof(ApiResponse<${name}Dto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _service.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"${name} not found.`" });
            
            return Ok(new ApiResponse<${name}Dto>(result));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while fetching ${name} with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"FETCH_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<${name}Dto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] Create${name}Dto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _service.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<${name}Dto>(result, `"${name} created successfully.`");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while creating ${name}`");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"CREATE_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpPut(`"{id}`")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Update(long id, [FromBody] Update${name}Dto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"${name} not found.`" });
            
            return Ok(new ApiResponse<bool>(true, `"${name} updated successfully.`"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while updating ${name} with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"UPDATE_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpDelete(`"{id}`")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Delete(long id, CancellationToken cancellationToken)
    {
        try
        {
            var deleted = await _service.DeleteAsync(id, cancellationToken);
            if (!deleted) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"${name} not found.`" });
            
            return Ok(new ApiResponse<bool>(true, `"${name} deleted successfully.`"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while deleting ${name} with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DELETE_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }
}
"@

    # Register in Program.cs
    $di = "builder.Services.AddScoped<I${name}Repository, ${name}Repository>();`r`nbuilder.Services.AddScoped<I${name}Service, ${name}Service>();"
    $program = Get-Content "$apiDir\Program.cs" -Raw
    if ($program -notmatch "I${name}Repository") {
        $program = $program -replace "// Register Repositories and Services", "// Register Repositories and Services`r`n$di"
        Set-Content -Path "$apiDir\Program.cs" -Value $program -Encoding UTF8
    }
}
Write-Host "Done."
