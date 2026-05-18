$baseDir = "d:\Office\SdxCore\src"

# Add project references to Common
dotnet add $baseDir\Services\Time\SdxCore.Time.Domain\SdxCore.Time.Domain.csproj reference $baseDir\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj
dotnet add $baseDir\Services\Time\SdxCore.Time.Application\SdxCore.Time.Application.csproj reference $baseDir\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj
dotnet add $baseDir\Services\Time\SdxCore.Time.Persistence\SdxCore.Time.Persistence.csproj reference $baseDir\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj
dotnet add $baseDir\Services\Time\SdxCore.Time.API\SdxCore.Time.API.csproj reference $baseDir\BuildingBlocks\SdxCore.Common\SdxCore.Common.csproj

# Create Domain Interface
$domainDir = "$baseDir\Services\Time\SdxCore.Time.Domain\Interfaces"
if (-not (Test-Path $domainDir)) { New-Item -ItemType Directory -Path $domainDir -Force | Out-Null }

Set-Content -Path "$domainDir\IDepartmentRepository.cs" -Value @"
using SdxCore.Time.Domain.Entities;
namespace SdxCore.Time.Domain.Interfaces;
public interface IDepartmentRepository {
    Task<IEnumerable<Department>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Department?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<Department> AddAsync(Department department, CancellationToken cancellationToken = default);
    Task UpdateAsync(Department department, CancellationToken cancellationToken = default);
}
"@ -Encoding UTF8

# Create Persistence Repository
$repoDir = "$baseDir\Services\Time\SdxCore.Time.Persistence\Repositories"
if (-not (Test-Path $repoDir)) { New-Item -ItemType Directory -Path $repoDir -Force | Out-Null }

Set-Content -Path "$repoDir\DepartmentRepository.cs" -Value @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;
namespace SdxCore.Time.Persistence.Repositories;
public class DepartmentRepository : IDepartmentRepository {
    private readonly TimeDbContext _dbContext;
    public DepartmentRepository(TimeDbContext dbContext) {
        _dbContext = dbContext;
    }
    public async Task<IEnumerable<Department>> GetAllAsync(CancellationToken cancellationToken = default) {
        return await _dbContext.Departments.AsNoTracking().ToListAsync(cancellationToken);
    }
    public async Task<Department?> GetByIdAsync(long id, CancellationToken cancellationToken = default) {
        return await _dbContext.Departments.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
    }
    public async Task<Department> AddAsync(Department department, CancellationToken cancellationToken = default) {
        _dbContext.Departments.Add(department);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return department;
    }
    public async Task UpdateAsync(Department department, CancellationToken cancellationToken = default) {
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
"@ -Encoding UTF8

# Update DepartmentService
Set-Content -Path "$baseDir\Services\Time\SdxCore.Time.Application\Services\DepartmentService.cs" -Value @"
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
namespace SdxCore.Time.Application.Services;
public class DepartmentService : IDepartmentService {
    private readonly IDepartmentRepository _repository;
    public DepartmentService(IDepartmentRepository repository) {
        _repository = repository;
    }
    public async Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default) {
        var depts = await _repository.GetAllAsync(cancellationToken);
        return depts.Select(d => new DepartmentDto {
            Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
        });
    }
    public async Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) {
        var d = await _repository.GetByIdAsync(id, cancellationToken);
        if (d == null) return null;
        return new DepartmentDto {
            Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
        };
    }
    public async Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default) {
        var entity = new Department {
            DepartmentCode = dto.DepartmentCode, DepartmentName = dto.DepartmentName,
            ParentDepartmentId = dto.ParentDepartmentId, Description = dto.Description,
            IsActive = true, CreatedAt = DateTime.UtcNow
        };
        await _repository.AddAsync(entity, cancellationToken);
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    public async Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default) {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;
        await _repository.UpdateAsync(entity, cancellationToken);
        return true;
    }
    public async Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default) {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        entity.IsActive = false;
        await _repository.UpdateAsync(entity, cancellationToken);
        return true;
    }
}
"@ -Encoding UTF8

# Update DepartmentsController to match LookupsController
Set-Content -Path "$baseDir\Services\Time\SdxCore.Time.API\Controllers\DepartmentsController.cs" -Value @"
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
[Route(`"api/v1/departments`")]
[GatewayOnly]
public class DepartmentsController : ControllerBase
{
    private readonly IDepartmentService _departmentService;
    private readonly ILogger<DepartmentsController> _logger;

    public DepartmentsController(IDepartmentService departmentService, ILogger<DepartmentsController> logger)
    {
        _departmentService = departmentService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<DepartmentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetAllAsync(cancellationToken);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while fetching all departments`");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DEPARTMENT_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpGet(`"{id}`")]
    [ProducesResponseType(typeof(DepartmentDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"Department not found.`" });
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while fetching department with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DEPARTMENT_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }
}
"@ -Encoding UTF8

Set-Content -Path "$baseDir\Services\Time\SdxCore.Time.API\Program.cs" -Value @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Time.Persistence.Data;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Repositories;
using SdxCore.Time.Application.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString(`"DefaultConnection`") 
    ?? `"Server=localhost;Database=SdxCore;Trusted_Connection=True;TrustServerCertificate=True;`";

builder.Services.AddDbContext<TimeDbContext>(options =>
    options.UseSqlServer(connectionString));

// Register Repositories and Services
builder.Services.AddScoped<IDepartmentRepository, DepartmentRepository>();
builder.Services.AddScoped<IDepartmentService, DepartmentService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
"@ -Encoding UTF8
