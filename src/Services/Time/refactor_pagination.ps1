$baseDir = "d:\Office\SdxCore\src"
$appDir = "$baseDir\Services\Time\SdxCore.Time.Application"
$domainDir = "$baseDir\Services\Time\SdxCore.Time.Domain"
$repoDir = "$baseDir\Services\Time\SdxCore.Time.Persistence\Repositories"
$apiDir = "$baseDir\Services\Time\SdxCore.Time.API"

Write-Host "Updating Repositories..."
# 1. Update IRepository
$irepoPath = "$baseDir\BuildingBlocks\SdxCore.Common\Data\IRepository.cs"
$irepo = Get-Content $irepoPath -Raw
if ($irepo -notmatch "GetAllPagedAsync") {
    $irepo = $irepo -replace "Task<IEnumerable<TEntity>> GetAllAsync\(CancellationToken cancellationToken = default\);", "Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);`r`n    Task<(IEnumerable<TEntity> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);"
    Set-Content -Path $irepoPath -Value $irepo -Encoding UTF8
}

# 2. Update BaseRepository
$baserepoPath = "$repoDir\BaseRepository.cs"
$baserepo = Get-Content $baserepoPath -Raw
if ($baserepo -notmatch "GetAllPagedAsync") {
    $pagedMethod = @"
    public virtual async Task<(IEnumerable<TEntity> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var count = await _dbSet.CountAsync(cancellationToken);
        var items = await _dbSet.AsNoTracking()
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, count);
    }
"@
    $baserepo = $baserepo -replace "public virtual async Task<IEnumerable<TEntity>> GetAllAsync", "$pagedMethod`r`n`r`n    public virtual async Task<IEnumerable<TEntity>> GetAllAsync"
    Set-Content -Path $baserepoPath -Value $baserepo -Encoding UTF8
}

Write-Host "Updating IServices..."
# 3. Update IServices
$iservices = Get-ChildItem "$appDir\Services\I*Service.cs"
foreach ($file in $iservices) {
    $content = Get-Content $file.FullName -Raw
    $name = $file.Name.Replace("Service.cs", "").Substring(1)
    
    if ($content -notmatch "using SdxCore.Common.Models;") {
        $content = $content -replace "using System.Collections.Generic;", "using System.Collections.Generic;`r`nusing SdxCore.Common.Models;"
    }
    
    $content = $content -replace "Task<IEnumerable<${name}Dto>> GetAllAsync\(CancellationToken cancellationToken = default\);", "Task<PagedResponse<IEnumerable<${name}Dto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);"
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

Write-Host "Updating Services..."
# 4. Update Services
$services = Get-ChildItem "$appDir\Services\*Service.cs" | Where-Object { $_.Name -notmatch "^I" }
foreach ($file in $services) {
    $content = Get-Content $file.FullName -Raw
    $name = $file.Name.Replace("Service.cs", "")
    
    if ($content -notmatch "using SdxCore.Common.Models;") {
        $content = $content -replace "using System;", "using System;`r`nusing SdxCore.Common.Models;"
    }
    if ($content -notmatch "using SdxCore.Time.Application.Helpers;") {
        $content = $content -replace "using System;", "using System;`r`nusing SdxCore.Time.Application.Helpers;"
    }
    
    $replacement = @"
    public async Task<PagedResponse<IEnumerable<${name}Dto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default) 
    {
        var result = await _repository.GetAllPagedAsync(filter.PageNumber, filter.PageSize, cancellationToken);
        var dtos = result.Items.Select(e => SimpleMapper.Map<${name}, ${name}Dto>(e));
        return new PagedResponse<IEnumerable<${name}Dto>>(dtos, filter.PageNumber, filter.PageSize, result.TotalCount);
    }
"@
    $pattern = "(?s)public async Task<IEnumerable<${name}Dto>> GetAllAsync.*?}\s+public async Task<${name}Dto\?>"
    $replacementWithNext = $replacement + "`r`n`r`n    public async Task<${name}Dto?>"
    $content = $content -replace $pattern, $replacementWithNext
    
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

Write-Host "Updating Controllers..."
# 5. Update Controllers
$controllers = Get-ChildItem "$apiDir\Controllers\*Controller.cs"
foreach ($file in $controllers) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "I(\w+)Service") {
        $name = $matches[1]
    } else {
        continue
    }

    $content = $content -replace "typeof\(ApiResponse<IEnumerable<${name}Dto>>\)", "typeof(PagedResponse<IEnumerable<${name}Dto>>)"
    
    $pattern = "(?s)public async Task<IActionResult> GetAll\(CancellationToken cancellationToken\).*?var result = await _service.GetAllAsync\(cancellationToken\);\s+return Ok\(new ApiResponse<IEnumerable<${name}Dto>>\(result, `"(.*?)`"\)\);\s+}"
    $replacement = @"
    public async Task<IActionResult> GetAll([FromQuery] PaginationFilter filter, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _service.GetAllAsync(filter, cancellationToken);
            return Ok(response);
        }
"@
    $content = $content -replace $pattern, $replacement
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
Write-Host "Done!"
