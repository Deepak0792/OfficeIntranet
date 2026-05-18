$baseDir = "d:\Office\SdxCore\src"

# 1. BaseRepository
$repoDir = "$baseDir\Services\Time\SdxCore.Time.Persistence\Repositories"
Set-Content -Path "$repoDir\BaseRepository.cs" -Value @"
using Microsoft.EntityFrameworkCore;
using SdxCore.Common.Data;
using SdxCore.Time.Persistence.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Persistence.Repositories;

public abstract class BaseRepository<TEntity> : IRepository<TEntity> where TEntity : class
{
    protected readonly TimeDbContext _dbContext;
    protected readonly DbSet<TEntity> _dbSet;

    protected BaseRepository(TimeDbContext dbContext)
    {
        _dbContext = dbContext;
        _dbSet = dbContext.Set<TEntity>();
    }

    public virtual async Task<TEntity?> GetByIdAsync(long id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }

    public virtual async Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.AsNoTracking().ToListAsync(cancellationToken);
    }

    public virtual async Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(predicate).ToListAsync(cancellationToken);
    }

    public virtual async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
        return entity;
    }

    public virtual async Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddRangeAsync(entities, cancellationToken);
    }

    public virtual void Update(TEntity entity)
    {
        _dbSet.Update(entity);
    }

    public virtual void Remove(TEntity entity)
    {
        _dbSet.Remove(entity);
    }

    public virtual void RemoveRange(IEnumerable<TEntity> entities)
    {
        _dbSet.RemoveRange(entities);
    }

    public virtual async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
"@ -Encoding UTF8

# 2. Update IDepartmentRepository
$domainDir = "$baseDir\Services\Time\SdxCore.Time.Domain\Interfaces"
Set-Content -Path "$domainDir\IDepartmentRepository.cs" -Value @"
using SdxCore.Common.Data;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Interfaces;

public interface IDepartmentRepository : IRepository<Department>
{
    // Add specific department methods here if needed in the future
}
"@ -Encoding UTF8

# 3. Update DepartmentRepository
Set-Content -Path "$repoDir\DepartmentRepository.cs" -Value @"
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class DepartmentRepository : BaseRepository<Department>, IDepartmentRepository
{
    public DepartmentRepository(TimeDbContext dbContext) : base(dbContext)
    {
    }
}
"@ -Encoding UTF8

# 4. Update DepartmentService
Set-Content -Path "$baseDir\Services\Time\SdxCore.Time.Application\Services\DepartmentService.cs" -Value @"
using SdxCore.Time.Application.DTOs;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public class DepartmentService : IDepartmentService 
{
    private readonly IDepartmentRepository _repository;
    
    public DepartmentService(IDepartmentRepository repository) 
    {
        _repository = repository;
    }
    
    public async Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var depts = await _repository.GetAllAsync(cancellationToken);
        return depts.Select(d => new DepartmentDto {
            Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
        });
    }
    
    public async Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default) 
    {
        var d = await _repository.GetByIdAsync(id, cancellationToken);
        if (d == null) return null;
        return new DepartmentDto {
            Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
            ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
        };
    }
    
    public async Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = new Department {
            DepartmentCode = dto.DepartmentCode, DepartmentName = dto.DepartmentName,
            ParentDepartmentId = dto.ParentDepartmentId, Description = dto.Description,
            IsActive = true, CreatedAt = DateTime.UtcNow
        };
        await _repository.AddAsync(entity, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);
        
        return await GetByIdAsync(entity.Id, cancellationToken) ?? throw new InvalidOperationException();
    }
    
    public async Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default) 
    {
        var entity = await _repository.GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        
        entity.DepartmentCode = dto.DepartmentCode;
        entity.DepartmentName = dto.DepartmentName;
        entity.ParentDepartmentId = dto.ParentDepartmentId;
        entity.Description = dto.Description;
        
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
"@ -Encoding UTF8

# 5. Update DepartmentsController
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
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<DepartmentDto>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<DepartmentDto>>(result, `"Successfully fetched departments.`"));
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
    [ProducesResponseType(typeof(ApiResponse<DepartmentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        try
        {
            var result = await _departmentService.GetByIdAsync(id, cancellationToken);
            if (result == null) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"Department not found.`" });
            
            return Ok(new ApiResponse<DepartmentDto>(result));
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

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<DepartmentDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Create([FromBody] CreateDepartmentDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            var result = await _departmentService.CreateAsync(dto, cancellationToken);
            var response = new ApiResponse<DepartmentDto>(result, `"Department created successfully.`");
            
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while creating department`");
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DEPARTMENT_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }

    [HttpPut(`"{id}`")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> Update(long id, [FromBody] UpdateDepartmentDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var updated = await _departmentService.UpdateAsync(id, dto, cancellationToken);
            if (!updated) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"Department not found.`" });
            
            return Ok(new ApiResponse<bool>(true, `"Department updated successfully.`"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while updating department with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DEPARTMENT_ERROR`",
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
            var deleted = await _departmentService.DeleteAsync(id, cancellationToken);
            if (!deleted) return NotFound(new ErrorResponse { ErrorCode = `"NOT_FOUND`", ErrorMessage = `"Department not found.`" });
            
            return Ok(new ApiResponse<bool>(true, `"Department deleted successfully.`"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, `"Error occurred while deleting department with ID {Id}`", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new ErrorResponse
            {
                ErrorCode = `"DEPARTMENT_ERROR`",
                ErrorMessage = `"An unexpected error occurred while processing the request.`"
            });
        }
    }
}
"@ -Encoding UTF8
