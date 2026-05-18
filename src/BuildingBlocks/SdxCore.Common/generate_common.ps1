$baseDir = "d:\Office\SdxCore\src\BuildingBlocks\SdxCore.Common"

if (-not (Test-Path "$baseDir\Data")) { New-Item -ItemType Directory -Path "$baseDir\Data" -Force | Out-Null }
if (-not (Test-Path "$baseDir\Models")) { New-Item -ItemType Directory -Path "$baseDir\Models" -Force | Out-Null }

Set-Content -Path "$baseDir\Data\IRepository.cs" -Value @"
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Common.Data;

public interface IRepository<TEntity> where TEntity : class
{
    Task<TEntity?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);
    
    Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task AddRangeAsync(IEnumerable<TEntity> entities, CancellationToken cancellationToken = default);
    
    void Update(TEntity entity);
    void Remove(TEntity entity);
    void RemoveRange(IEnumerable<TEntity> entities);
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
"@ -Encoding UTF8

Set-Content -Path "$baseDir\Models\ApiResponse.cs" -Value @"
using System.Collections.Generic;

namespace SdxCore.Common.Models;

public class ApiResponse<T>
{
    public bool Succeeded { get; set; }
    public string? Message { get; set; }
    public T? Data { get; set; }
    public List<string>? Errors { get; set; }

    public ApiResponse() 
    { 
    }

    public ApiResponse(T data, string? message = null)
    {
        Succeeded = true;
        Message = message;
        Data = data;
    }

    public ApiResponse(string message, List<string>? errors = null)
    {
        Succeeded = false;
        Message = message;
        Errors = errors;
    }
}
"@ -Encoding UTF8

Set-Content -Path "$baseDir\Models\PaginationFilter.cs" -Value @"
namespace SdxCore.Common.Models;

public class PaginationFilter
{
    private const int MaxPageSize = 100;
    private int _pageSize = 10;
    private int _pageNumber = 1;

    public int PageNumber 
    { 
        get => _pageNumber; 
        set => _pageNumber = (value < 1) ? 1 : value; 
    }
    
    public int PageSize 
    { 
        get => _pageSize; 
        set => _pageSize = (value > MaxPageSize) ? MaxPageSize : (value < 1 ? 10 : value); 
    }

    public PaginationFilter()
    {
    }

    public PaginationFilter(int pageNumber, int pageSize)
    {
        PageNumber = pageNumber;
        PageSize = pageSize;
    }
}
"@ -Encoding UTF8

Set-Content -Path "$baseDir\Models\PagedResponse.cs" -Value @"
using System;

namespace SdxCore.Common.Models;

public class PagedResponse<T> : ApiResponse<T>
{
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }

    public PagedResponse(T data, int pageNumber, int pageSize, int totalRecords)
    {
        Data = data;
        PageNumber = pageNumber;
        PageSize = pageSize;
        TotalRecords = totalRecords;
        TotalPages = pageSize > 0 ? (int)Math.Ceiling(totalRecords / (double)pageSize) : 0;
        
        Succeeded = true;
        Message = null;
        Errors = null;
    }
}
"@ -Encoding UTF8
