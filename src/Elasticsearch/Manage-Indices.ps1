param (
    [string]$ElasticUrl = "http://localhost:9200",
    [string]$IndexName = "sdxcore-employees",
    [string]$MappingFile = ".\mappings\employee.json"
)

$ErrorActionPreference = "Stop"

# Create a new index with timestamp
$timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
$newIndexName = "$IndexName-$timestamp"

Write-Host "Creating new index: $newIndexName"
$mappingJson = Get-Content -Raw $MappingFile
Invoke-RestMethod -Uri "$ElasticUrl/$newIndexName" -Method Put -Body $mappingJson -ContentType "application/json"

# Check if read alias exists
$aliasUrl = "$ElasticUrl/_alias/$IndexName-read"
$aliasExists = $false
try {
    $response = Invoke-RestMethod -Uri $aliasUrl -Method Get -ErrorAction Stop
    $aliasExists = $true
} catch {
    # Alias doesn't exist
}

$actions = @()
if ($aliasExists) {
    # Get current index pointing to read alias
    $currentIndexes = (Invoke-RestMethod -Uri $aliasUrl -Method Get).PSObject.Properties.Name
    foreach ($idx in $currentIndexes) {
        $actions += "{ `"remove`": { `"index`": `"$idx`", `"alias`": `"$IndexName-read`" } }"
        $actions += "{ `"remove`": { `"index`": `"$idx`", `"alias`": `"$IndexName-write`" } }"
    }
}

# Point aliases to new index
$actions += "{ `"add`": { `"index`": `"$newIndexName`", `"alias`": `"$IndexName-read`" } }"
$actions += "{ `"add`": { `"index`": `"$newIndexName`", `"alias`": `"$IndexName-write`" } }"

$aliasUpdateBody = "{ `"actions`": [ " + ($actions -join ",") + " ] }"

Write-Host "Updating aliases..."
Invoke-RestMethod -Uri "$ElasticUrl/_aliases" -Method Post -Body $aliasUpdateBody -ContentType "application/json"

Write-Host "Successfully initialized Elasticsearch indices!"
