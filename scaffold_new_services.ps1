$ErrorActionPreference = "Stop"

$solutionFile = "d:\Office\SdxCore\SdxCore.sln"
$srcDir = "d:\Office\SdxCore\src\Services"
$buildingBlocksDir = "d:\Office\SdxCore\src\BuildingBlocks"

$services = @("Employee", "Workflow", "Attendance", "Notification")

foreach ($svc in $services) {
    Write-Host "Scaffolding $svc microservice..."
    $svcDir = "$srcDir\$svc"
    if (-Not (Test-Path $svcDir)) { New-Item -ItemType Directory -Path $svcDir | Out-Null }
    
    $api = "SdxCore.$svc.API"
    $app = "SdxCore.$svc.Application"
    $dom = "SdxCore.$svc.Domain"
    $per = "SdxCore.$svc.Persistence"
    
    # Create projects
    if (-Not (Test-Path "$svcDir\$api")) { dotnet new webapi -n $api -o "$svcDir\$api" --use-controllers }
    if (-Not (Test-Path "$svcDir\$app")) { dotnet new classlib -n $app -o "$svcDir\$app" }
    if (-Not (Test-Path "$svcDir\$dom")) { dotnet new classlib -n $dom -o "$svcDir\$dom" }
    if (-Not (Test-Path "$svcDir\$per")) { dotnet new classlib -n $per -o "$svcDir\$per" }
    
    # Delete default classes
    Remove-Item -Path "$svcDir\$app\Class1.cs" -ErrorAction SilentlyContinue
    Remove-Item -Path "$svcDir\$dom\Class1.cs" -ErrorAction SilentlyContinue
    Remove-Item -Path "$svcDir\$per\Class1.cs" -ErrorAction SilentlyContinue
    Remove-Item -Path "$svcDir\$api\WeatherForecast.cs" -ErrorAction SilentlyContinue
    Remove-Item -Path "$svcDir\$api\Controllers\WeatherForecastController.cs" -ErrorAction SilentlyContinue
    
    # Add to solution
    dotnet sln $solutionFile add "$svcDir\$api\$api.csproj"
    dotnet sln $solutionFile add "$svcDir\$app\$app.csproj"
    dotnet sln $solutionFile add "$svcDir\$dom\$dom.csproj"
    dotnet sln $solutionFile add "$svcDir\$per\$per.csproj"
    
    # Project References (Clean Architecture)
    dotnet add "$svcDir\$api\$api.csproj" reference "$svcDir\$app\$app.csproj" "$svcDir\$per\$per.csproj"
    dotnet add "$svcDir\$app\$app.csproj" reference "$svcDir\$dom\$dom.csproj"
    dotnet add "$svcDir\$per\$per.csproj" reference "$svcDir\$dom\$dom.csproj"
    
    # Common/Shared references (if they exist)
    if (Test-Path "$buildingBlocksDir\SdxCore.Common\SdxCore.Common.csproj") {
        dotnet add "$svcDir\$app\$app.csproj" reference "$buildingBlocksDir\SdxCore.Common\SdxCore.Common.csproj"
        dotnet add "$svcDir\$api\$api.csproj" reference "$buildingBlocksDir\SdxCore.Common\SdxCore.Common.csproj"
    }
}

# Attendance Processor
Write-Host "Scaffolding Attendance Processor..."
$procName = "SdxCore.Attendance.Processor"
$procDir = "$srcDir\Attendance\$procName"
if (-Not (Test-Path $procDir)) { dotnet new worker -n $procName -o $procDir }
Remove-Item -Path "$procDir\Worker.cs" -ErrorAction SilentlyContinue
dotnet sln $solutionFile add "$procDir\$procName.csproj"
dotnet add "$procDir\$procName.csproj" reference "$srcDir\Attendance\SdxCore.Attendance.Application\SdxCore.Attendance.Application.csproj"

# File API
Write-Host "Scaffolding File API..."
$fileApi = "SdxCore.File.API"
$fileDir = "$srcDir\File"
if (-Not (Test-Path $fileDir)) { New-Item -ItemType Directory -Path $fileDir | Out-Null }
if (-Not (Test-Path "$fileDir\$fileApi")) { dotnet new webapi -n $fileApi -o "$fileDir\$fileApi" --use-controllers }
Remove-Item -Path "$fileDir\$fileApi\WeatherForecast.cs" -ErrorAction SilentlyContinue
Remove-Item -Path "$fileDir\$fileApi\Controllers\WeatherForecastController.cs" -ErrorAction SilentlyContinue
dotnet sln $solutionFile add "$fileDir\$fileApi\$fileApi.csproj"

# FileStorage BuildingBlock
Write-Host "Scaffolding FileStorage building block..."
$fsAbstractions = "SdxCore.FileStorage.Abstractions"
$fsImpl = "SdxCore.FileStorage.SharedFileSystem"
$fsDir = "$buildingBlocksDir\SdxCore.FileStorage"
if (-Not (Test-Path $fsDir)) { New-Item -ItemType Directory -Path $fsDir | Out-Null }
if (-Not (Test-Path "$fsDir\$fsAbstractions")) { dotnet new classlib -n $fsAbstractions -o "$fsDir\$fsAbstractions" }
if (-Not (Test-Path "$fsDir\$fsImpl")) { dotnet new classlib -n $fsImpl -o "$fsDir\$fsImpl" }
Remove-Item -Path "$fsDir\$fsAbstractions\Class1.cs" -ErrorAction SilentlyContinue
Remove-Item -Path "$fsDir\$fsImpl\Class1.cs" -ErrorAction SilentlyContinue
dotnet sln $solutionFile add "$fsDir\$fsAbstractions\$fsAbstractions.csproj"
dotnet sln $solutionFile add "$fsDir\$fsImpl\$fsImpl.csproj"
dotnet add "$fsDir\$fsImpl\$fsImpl.csproj" reference "$fsDir\$fsAbstractions\$fsAbstractions.csproj"

Write-Host "Scaffolding Complete!"
