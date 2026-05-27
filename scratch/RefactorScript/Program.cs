using System;
using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        var dir = @"d:\Office\SdxCore\src\Services\Time\SdxCore.Time.Application\Services";
        var files = Directory.GetFiles(dir, "*.cs");
        foreach(var file in files)
        {
            if (file.EndsWith("CountryService.cs")) continue;
            var content = File.ReadAllText(file);
            var entityName = Path.GetFileNameWithoutExtension(file).Replace("Service", "");
            
            // 1. Add Caching namespace
            if (!content.Contains("using SdxCore.Common.Caching;"))
            {
                content = content.Replace("using SdxCore.Time.Domain.DTOs.Request;", "using SdxCore.Common.Caching;\r\nusing SdxCore.Time.Domain.DTOs.Request;");
            }

            // 2. Add ICacheService to constructor
            var ctorRegex = new Regex($@"private readonly I{entityName}Repository _repository;\s+public {entityName}Service\(I{entityName}Repository repository\)\s+{{\s+_repository = repository;\s+}}");
            var ctorReplacement = $@"private readonly I{entityName}Repository _repository;
    private readonly ICacheService _cacheService;
    private readonly ICacheKeyBuilder _cacheKeyBuilder;
    
    public {entityName}Service(I{entityName}Repository repository, ICacheService cacheService, ICacheKeyBuilder cacheKeyBuilder) 
    {{
        _repository = repository;
        _cacheService = cacheService;
        _cacheKeyBuilder = cacheKeyBuilder;
    }}";
            content = ctorRegex.Replace(content, ctorReplacement);

            // 3. Update GetAllAsync (IEnumerable)
            var getAllRegex = new Regex($@"public async Task<IEnumerable<{entityName}Response>> GetAllAsync\(CancellationToken cancellationToken = default\)\s+{{\s+var entities = await _repository\.GetAllAsync\(cancellationToken\);\s+return entities\.Select\(e => SimpleMapper\.Map<{entityName}, {entityName}Response>\(e\)\);\s+}}");
            var getAllReplacement = $@"public async Task<IEnumerable<{entityName}Response>> GetAllAsync(CancellationToken cancellationToken = default) 
    {{
        var cacheKey = _cacheKeyBuilder.BuildKey(""{entityName.ToLower()}"", ""all"");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {{
            var entities = await _repository.GetAllAsync(ct);
            return entities.Select(e => SimpleMapper.Map<{entityName}, {entityName}Response>(e));
        }}, CacheOptions.StaticMasterData, cancellationToken);
    }}";
            content = getAllRegex.Replace(content, getAllReplacement);

            // 4. Update GetByIdAsync (short or int)
            var getByIdRegex = new Regex($@"public async Task<{entityName}Response\?> GetByIdAsync\((short|int) id, CancellationToken cancellationToken = default\)\s+{{\s+var entity = await _repository\.GetByIdAsync\(id, cancellationToken\);\s+if \(entity == null\) return null;\s+return SimpleMapper\.Map<{entityName}, {entityName}Response>\(entity\);\s+}}");
            var getByIdReplacement = $@"public async Task<{entityName}Response?> GetByIdAsync($1 id, CancellationToken cancellationToken = default) 
    {{
        var cacheKey = _cacheKeyBuilder.BuildKey(""{entityName.ToLower()}"", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {{
            var entity = await _repository.GetByIdAsync(id, ct);
            if (entity == null) return null;
            return SimpleMapper.Map<{entityName}, {entityName}Response>(entity);
        }}, CacheOptions.StaticMasterData, cancellationToken);
    }}";
            content = getByIdRegex.Replace(content, getByIdReplacement);

            // Department special GetById
            var deptGetByIdRegex = new Regex($@"public async Task<DepartmentResponse\?> GetByIdAsync\((short|int) id, CancellationToken cancellationToken = default\)\s+{{\s+var d = await _repository\.GetByIdAsync\(id, cancellationToken\);\s+if \(d == null\) return null;\s+return new DepartmentResponse {{\s+Id = d\.Id, DepartmentCode = d\.DepartmentCode, DepartmentName = d\.DepartmentName,\s+ParentDepartmentId = d\.ParentDepartmentId, Description = d\.Description, IsActive = d\.IsActive\s+}};\s+}}");
            var deptGetByIdReplacement = $@"public async Task<DepartmentResponse?> GetByIdAsync($1 id, CancellationToken cancellationToken = default) 
    {{
        var cacheKey = _cacheKeyBuilder.BuildKey(""{entityName.ToLower()}"", id.ToString());
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {{
            var d = await _repository.GetByIdAsync(id, ct);
            if (d == null) return null;
            return new DepartmentResponse {{
                Id = d.Id, DepartmentCode = d.DepartmentCode, DepartmentName = d.DepartmentName,
                ParentDepartmentId = d.ParentDepartmentId, Description = d.Description, IsActive = d.IsActive
            }};
        }}, CacheOptions.StaticMasterData, cancellationToken);
    }}";
            content = deptGetByIdRegex.Replace(content, deptGetByIdReplacement);

            // BiometricDevice special GetAllPagedAsync
            var bioGetAllRegex = new Regex($@"public async Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync\(PaginationFilter filter, CancellationToken cancellationToken = default\)\s+{{\s+var result = await _repository\.GetAllPagedAsync\(filter\.PageNumber, filter\.PageSize, cancellationToken\);\s+var dtos = result\.Items\.Select\(e => SimpleMapper\.Map<BiometricDevice, BiometricDeviceResponse>\(e\)\);\s+return new PagedResponse<IEnumerable<BiometricDeviceResponse>>\(dtos, filter\.PageNumber, filter\.PageSize, result\.TotalCount\);\s+}}");
            var bioGetAllReplacement = $@"public async Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {{
        var cacheKey = _cacheKeyBuilder.BuildKey(""{entityName.ToLower()}"", $""page:{{filter.PageNumber}}:{{filter.PageSize}}"");
        return await _cacheService.GetOrSetAsync(cacheKey, async (ct) =>
        {{
            var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, ct);
            var dtos = result.Items.Select(e => SimpleMapper.Map<BiometricDevice, BiometricDeviceResponse>(e));
            return new PagedResponse<IEnumerable<BiometricDeviceResponse>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
        }}, CacheOptions.StaticMasterData, cancellationToken);
    }}";
            content = bioGetAllRegex.Replace(content, bioGetAllReplacement);

            File.WriteAllText(file, content);
        }
    }
}
