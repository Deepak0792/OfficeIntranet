$baseDir = "d:\Office\SdxCore\src\Services\Time"

function Write-File ($path, $content) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $path -Value $content.Trim() -Encoding UTF8
}

Write-Host "Generating Application DTOs..."
$appDir = "$baseDir\SdxCore.Time.Application"
$dtoDir = "$appDir\DTOs"

Write-File "$dtoDir\DepartmentDto.cs" @"
namespace SdxCore.Time.Application.DTOs;

public class DepartmentDto
{
    public long Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public long? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}

public class CreateDepartmentDto
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public long? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
}

public class UpdateDepartmentDto : CreateDepartmentDto { }
"@

Write-File "$dtoDir\LegalEntityDto.cs" @"
namespace SdxCore.Time.Application.DTOs;

public class LegalEntityDto
{
    public long Id { get; set; }
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public bool IsActive { get; set; }
}

public class CreateLegalEntityDto
{
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
}

public class UpdateLegalEntityDto : CreateLegalEntityDto { }
"@

Write-File "$dtoDir\OfficeLocationDto.cs" @"
namespace SdxCore.Time.Application.DTOs;

public class OfficeLocationDto
{
    public long Id { get; set; }
    public long LegalEntityId { get; set; }
    public long CountryId { get; set; }
    public long? RegionId { get; set; }
    public required string LocationCode { get; set; }
    public required string LocationName { get; set; }
    public string? City { get; set; }
    public bool IsHeadOffice { get; set; }
    public bool IsActive { get; set; }
}

public class CreateOfficeLocationDto
{
    public long LegalEntityId { get; set; }
    public long CountryId { get; set; }
    public long? RegionId { get; set; }
    public required string LocationCode { get; set; }
    public required string LocationName { get; set; }
    public string? City { get; set; }
    public bool IsHeadOffice { get; set; }
}

public class UpdateOfficeLocationDto : CreateOfficeLocationDto { }
"@


Write-Host "Generating Application Interfaces and Services..."
$svcDir = "$appDir\Services"

Write-File "$svcDir\IDepartmentService.cs" @"
using SdxCore.Time.Application.DTOs;

namespace SdxCore.Time.Application.Services;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}
"@

Write-File "$svcDir\DepartmentService.cs" @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Application.Services;

public class DepartmentService : IDepartmentService
{
    private readonly TimeDbContext _dbContext;

    public DepartmentService(TimeDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.Departments
            .AsNoTracking()
            .Select(d => new DepartmentDto
            {
                Id = d.Id,
                DepartmentCode = d.DepartmentCode,
                DepartmentName = d.DepartmentName,
                ParentDepartmentId = d.ParentDepartmentId,
                Description = d.Description,
                IsActive = d.IsActive
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default)
    {
        var d = await _dbContext.Departments.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (d == null) return null;
        
        return new DepartmentDto
        {
            Id = d.Id,
            DepartmentCode = d.DepartmentCode,
            DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId,
            Description = d.Description,
            IsActive = d.IsActive
        };
    }

    public async Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default)
    {
        var entity = new Department
        {
            DepartmentCode = dto.DepartmentCode,
            DepartmentName = dto.DepartmentName,
            ParentDepartmentId = dto.ParentDepartmentId,
            Description = dto.Description,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _dbContext.Departments.Add(entity);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }

    public async Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await _dbContext.Departments.FindAsync([id], cancellationToken: cancellationToken);
        if (entity == null) return false;

        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;

        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default)
    {
        var entity = await _dbContext.Departments.FindAsync([id], cancellationToken: cancellationToken);
        if (entity == null) return false;

        entity.IsActive = false; // Soft delete
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }
}
"@


Write-Host "Generating API Controllers..."
$apiDir = "$baseDir\SdxCore.Time.API\Controllers"

Write-File "$apiDir\DepartmentsController.cs" @"
using Microsoft.AspNetCore.Mvc;
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Application.Services;

namespace SdxCore.Time.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class DepartmentsController : ControllerBase
{
    private readonly IDepartmentService _departmentService;

    public DepartmentsController(IDepartmentService departmentService)
    {
        _departmentService = departmentService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetAllAsync(cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        var result = await _departmentService.GetByIdAsync(id, cancellationToken);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDepartmentDto dto, CancellationToken cancellationToken)
    {
        var result = await _departmentService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(long id, [FromBody] UpdateDepartmentDto dto, CancellationToken cancellationToken)
    {
        var updated = await _departmentService.UpdateAsync(id, dto, cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(long id, CancellationToken cancellationToken)
    {
        var deleted = await _departmentService.DeleteAsync(id, cancellationToken);
        if (!deleted) return NotFound();
        return NoContent();
    }
}
"@

Write-Host "Done."
