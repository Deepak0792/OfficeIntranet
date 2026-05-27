param (
    [string]$ElasticUrl = "http://localhost:9200",
    [string]$IndexName = "sdxcore-employees",
    [string]$MappingFile = ".\mappings\employee.json"
)

$ErrorActionPreference = "Stop"

# 1. Create a new index with timestamp
$timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
$newIndexName = "$IndexName-$timestamp"

Write-Host "Creating new index: $newIndexName"
$mappingJson = Get-Content -Raw $MappingFile
Invoke-RestMethod -Uri "$ElasticUrl/$newIndexName" -Method Put -Body $mappingJson -ContentType "application/json"

# 2. Reindex data from current read alias
Write-Host "Reindexing data..."
$reindexBody = @{
    source = @{
        index = "$IndexName-read"
    }
    dest = @{
        index = $newIndexName
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "$ElasticUrl/_reindex" -Method Post -Body $reindexBody -ContentType "application/json"

# 3. Switch aliases
$aliasUrl = "$ElasticUrl/_alias/$IndexName-read"
$currentIndexes = (Invoke-RestMethod -Uri $aliasUrl -Method Get).PSObject.Properties.Name

$actions = @()
foreach ($idx in $currentIndexes) {
    $actions += "{ `"remove`": { `"index`": `"$idx`", `"alias`": `"$IndexName-read`" } }"
    $actions += "{ `"remove`": { `"index`": `"$idx`", `"alias`": `"$IndexName-write`" } }"
}
$actions += "{ `"add`": { `"index`": `"$newIndexName`", `"alias`": `"$IndexName-read`" } }"
$actions += "{ `"add`": { `"index`": `"$newIndexName`", `"alias`": `"$IndexName-write`" } }"

$aliasUpdateBody = "{ `"actions`": [ " + ($actions -join ",") + " ] }"

Write-Host "Switching aliases to new index..."
Invoke-RestMethod -Uri "$ElasticUrl/_aliases" -Method Post -Body $aliasUpdateBody -ContentType "application/json"

# 4. Optional: Delete old indexes (commented out for safety)
# foreach ($idx in $currentIndexes) {
#     Write-Host "Deleting old index $idx..."
#     Invoke-RestMethod -Uri "$ElasticUrl/$idx" -Method Delete
# }

Write-Host "Rebuild Complete!"
