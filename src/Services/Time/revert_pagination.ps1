$baseDir = "d:\Office\SdxCore\src"
$appDir = "$baseDir\Services\Time\SdxCore.Time.Application"
$apiDir = "$baseDir\Services\Time\SdxCore.Time.API"

# Revert IServices
$iservices = Get-ChildItem "$appDir\Services\I*Service.cs" | Where-Object { $_.Name -notmatch "IBiometricDeviceService" }
foreach ($file in $iservices) {
    $content = Get-Content $file.FullName -Raw
    $name = $file.Name.Replace("Service.cs", "").Substring(1)
    
    $content = $content -replace "Task<PagedResponse<IEnumerable<${name}Dto>>> GetAllAsync\(PaginationFilter filter, CancellationToken cancellationToken = default\);", "Task<IEnumerable<${name}Dto>> GetAllAsync(CancellationToken cancellationToken = default);"
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

# Revert Services
$services = Get-ChildItem "$appDir\Services\*Service.cs" | Where-Object { $_.Name -notmatch "^I" -and $_.Name -notmatch "BiometricDeviceService" }
foreach ($file in $services) {
    $content = Get-Content $file.FullName -Raw
    $name = $file.Name.Replace("Service.cs", "")
    
    $pattern = "(?s)public async Task<PagedResponse<IEnumerable<${name}Dto>>> GetAllAsync\(PaginationFilter filter, CancellationToken cancellationToken = default\).*?return new PagedResponse<IEnumerable<${name}Dto>>\(dtos, filter.PageNumber, filter.PageSize, result.TotalCount\);\s+}"
    $replacement = @"
    public async Task<IEnumerable<${name}Dto>> GetAllAsync(CancellationToken cancellationToken = default) 
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(e => SimpleMapper.Map<${name}, ${name}Dto>(e));
    }
"@
    $content = $content -replace $pattern, $replacement
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

# Revert Controllers
$controllers = Get-ChildItem "$apiDir\Controllers\*Controller.cs" | Where-Object { $_.Name -notmatch "BiometricDevicesController" }
foreach ($file in $controllers) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "I(\w+)Service\s+_(\w+)Service;") {
        $name = $matches[1]
        $varName = $matches[2] + "Service"
    } elseif ($content -match "I(\w+)Service\s+_(service);") {
        $name = $matches[1]
        $varName = "service"
    } else {
        continue
    }

    $plural = $file.Name.Replace("Controller.cs", "")
    
    $content = $content -replace "typeof\(PagedResponse<IEnumerable<${name}Dto>>\)", "typeof(ApiResponse<IEnumerable<${name}Dto>>)"
    
    $pattern = "(?s)public async Task<IActionResult> GetAll\(\[FromQuery\] PaginationFilter filter, CancellationToken cancellationToken\)\s+\{\s+try\s+\{\s+var response = await _${varName}\.GetAllAsync\(filter, cancellationToken\);\s+return Ok\(response\);\s+\}"
    $replacement = @"
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        try
        {
            var result = await _${varName}.GetAllAsync(cancellationToken);
            return Ok(new ApiResponse<IEnumerable<${name}Dto>>(result, `"Successfully fetched ${plural}.`"));
        }
"@
    $content = $content -replace $pattern, $replacement
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
