#Requires -Version 5.1
<#
.SYNOPSIS
    Complete build script that generates DACPAC, full deployment script, and delta scripts.

.DESCRIPTION
    This is the master build script that:
    1. Builds the SSDT project to generate DACPAC
    2. Generates full consolidated deployment script (all sprints)
    3. Generates delta deployment scripts for specified sprint ranges
    
    This script combines Build-DeploymentScripts.ps1 functionality with
    standalone delta script generation.

.PARAMETER Configuration
    Build configuration (Debug or Release). Default: Release

.PARAMETER TargetServer
    Target SQL Server name for script generation. Default: localhost

.PARAMETER TargetDatabase
    Target database name for script generation. Default: SdxCore

.PARAMETER OutputPath
    Directory where all scripts will be generated. Default: .\DeploymentScripts

.PARAMETER SkipBuild
    Skip the build step (use existing DACPAC)

.PARAMETER SkipFullScript
    Skip full deployment script generation

.PARAMETER SkipDeltaScripts
    Skip delta script generation

.PARAMETER IntegratedSecurity
    Use Windows Authentication. Default: $true

.PARAMETER Username
    SQL Server username (if not using Integrated Security)

.PARAMETER Password
    SQL Server password (if not using Integrated Security)

.EXAMPLE
    .\Build-All.ps1
    Builds project and generates all scripts with default settings

.EXAMPLE
    .\Build-All.ps1 -TargetServer "prod-server" -TargetDatabase "SdxCore_Prod"
    Generates scripts for production server

.EXAMPLE
    .\Build-All.ps1 -SkipBuild -SkipFullScript
    Only generates delta scripts using existing DACPAC
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [Parameter(Mandatory=$false)]
    [string]$TargetServer = 'localhost',
    
    [Parameter(Mandatory=$false)]
    [string]$TargetDatabase = 'SdxCore',
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\DeploymentScripts",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipFullScript,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipDeltaScripts,
    
    [Parameter(Mandatory=$false)]
    [switch]$IntegratedSecurity = $true,
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')]   $Message" -ForegroundColor Gray
}

# ============================================================================
# Main Script
# ============================================================================

Write-Header "SdxCore Database - Complete Build Process"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$startTime = Get-Date

Write-Info "Configuration: $Configuration"
Write-Info "Target: $TargetServer/$TargetDatabase"
Write-Info "Output: $OutputPath"
Write-Info "Timestamp: $timestamp"
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Info "Created output directory: $OutputPath"
}

$results = @{
    Build = $null
    FullScript = $null
    DeltaScripts = @()
}

# ============================================================================
# Step 1: Build SSDT Project
# ============================================================================

if (-not $SkipBuild) {
    Write-Header "Step 1: Building SSDT Project"
    
    $projectFile = Join-Path $scriptRoot "SdxCore.Database.sqlproj"
    
    if (-not (Test-Path $projectFile)) {
        Write-Host "ERROR: Project file not found: $projectFile" -ForegroundColor Red
        exit 1
    }
    
    Write-Step "Building SdxCore.Database.sqlproj ($Configuration)..."
    
    try {
        $msbuildArgs = @(
            $projectFile,
            "/p:Configuration=$Configuration",
            "/v:minimal",
            "/nologo"
        )
        
        & msbuild $msbuildArgs
        
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }
        
        $results.Build = "Success"
        Write-Success "Build completed successfully"
    } catch {
        $results.Build = "Failed: $_"
        Write-Host "Build failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Info "Skipping build step (using existing DACPAC)"
    $results.Build = "Skipped"
}

# Verify DACPAC exists (only if not skipping full script generation that needs it)
if (-not $SkipBuild -or (-not $SkipFullScript -and $false)) {
    # Note: We no longer need DACPAC for full script generation since we use Generate-FullScript.ps1
    # This check is kept for reference but is now optional
    $buildOutput = Join-Path $scriptRoot "bin\$Configuration"
    $dacpacFile = Join-Path $buildOutput "SdxCore.Database.dacpac"

    if (-not (Test-Path $dacpacFile)) {
        Write-Info "Note: DACPAC file not found (not required for SQL script generation)"
        $dacpacFile = $null
    } else {
        $dacpacSizeMB = [Math]::Round((Get-Item $dacpacFile).Length / 1MB, 2)
        Write-Info ('DACPAC: ' + $dacpacFile + ' (' + $dacpacSizeMB + ' MB)')
    }
}

# ============================================================================
# Step 2: Generate Full Deployment Script
# ============================================================================

if (-not $SkipFullScript) {
    Write-Header "Step 2: Generating Full Deployment Script"
    
    # Use Generate-FullScript.ps1 to create consolidated SQL script
    $fullScriptGenerator = Join-Path $scriptRoot "Generate-FullScript.ps1"
    
    if (-not (Test-Path $fullScriptGenerator)) {
        Write-Warning "Generate-FullScript.ps1 not found. Skipping full script generation."
        $results.FullScript = "Skipped (Generator script not found)"
    } else {
        Write-Step "Generating full consolidated deployment script..."
        
        try {
            # Call Generate-FullScript.ps1
            & $fullScriptGenerator -OutputPath $OutputPath
            
            $fullScriptPath = Join-Path $OutputPath "SdxCore.Database.Full.sql"
            
            if (Test-Path $fullScriptPath) {
                $results.FullScript = $fullScriptPath
                Write-Success "Full deployment script generated"
                Write-Info "  File: $fullScriptPath"
                $scriptSizeKB = [Math]::Round((Get-Item $fullScriptPath).Length / 1KB, 2)
                Write-Info ('  Size: ' + $scriptSizeKB + ' KB')
            } else {
                throw "Script file was not created"
            }
        } catch {
            $results.FullScript = "Failed: $_"
            Write-Warning "Full script generation failed: $_"
        }
    }
} else {
    Write-Info "Skipping full deployment script generation"
    $results.FullScript = "Skipped"
}

# ============================================================================
# Step 3: Generate Delta Script
# ============================================================================

if (-not $SkipDeltaScripts) {
    Write-Header "Step 3: Generating Delta Deployment Script"
    
    # Use Generate-DeltaScript.ps1 to create single delta script
    $deltaScriptGenerator = Join-Path $scriptRoot "Generate-DeltaScript.ps1"
    
    if (-not (Test-Path $deltaScriptGenerator)) {
        Write-Warning "Generate-DeltaScript.ps1 not found. Skipping delta script generation."
        $results.DeltaScripts = @("Skipped (Generator script not found)")
    } else {
        Write-Step "Generating delta deployment script..."
        
        try {
            # Call Generate-DeltaScript.ps1
            & $deltaScriptGenerator -OutputPath $OutputPath
            
            $deltaScriptPath = Join-Path $OutputPath "SdxCore.Database.Delta.sql"
            
            if (Test-Path $deltaScriptPath) {
                $results.DeltaScripts = @($deltaScriptPath)
                Write-Success "Delta deployment script generated"
                Write-Info "  File: $deltaScriptPath"
                $deltaScriptSizeKB = [Math]::Round((Get-Item $deltaScriptPath).Length / 1KB, 2)
                Write-Info ('  Size: ' + $deltaScriptSizeKB + ' KB')
            } else {
                throw "Delta script file was not created"
            }
        } catch {
            $results.DeltaScripts = @("Failed: $_")
            Write-Warning "Delta script generation failed: $_"
        }
    }
} else {
    Write-Info "Skipping delta script generation"
    $results.DeltaScripts = @("Skipped")
}

# ============================================================================
# Summary
# ============================================================================

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Header "Build Process Complete"

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Duration:             $($duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host "  Configuration:        $Configuration" -ForegroundColor White
if ($dacpacFile) {
    Write-Host "  DACPAC:               $dacpacFile" -ForegroundColor White
} else {
    Write-Host "  DACPAC:               Not generated (SQL scripts only)" -ForegroundColor White
}
Write-Host "  Output Directory:     $OutputPath" -ForegroundColor White
Write-Host ""

Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Build:                $($results.Build)" -ForegroundColor White
Write-Host "  Full Script:          $($results.FullScript)" -ForegroundColor White
if ($results.DeltaScripts -is [array] -and $results.DeltaScripts[0] -ne "Skipped" -and $results.DeltaScripts[0] -notlike "Failed:*") {
    Write-Host "  Delta Script:         Generated" -ForegroundColor White
} else {
    Write-Host "  Delta Script:         $($results.DeltaScripts[0])" -ForegroundColor White
}
Write-Host ""

Write-Host "Generated Files:" -ForegroundColor Cyan
$allFiles = Get-ChildItem $OutputPath -Filter "*.sql" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -eq "SdxCore.Database.Full.sql" -or $_.Name -eq "SdxCore.Database.Delta.sql" } |
            Sort-Object Name

if ($allFiles.Count -gt 0) {
    foreach ($file in $allFiles) {
        $sizeKB = [Math]::Round($file.Length / 1KB, 2)
        $type = if ($file.Name -eq "SdxCore.Database.Full.sql") { "FULL" } elseif ($file.Name -eq "SdxCore.Database.Delta.sql") { "DELTA" } else { "OTHER" }
        Write-Host ('  [' + $type + '] ' + $file.Name + ' (' + $sizeKB + ' KB)') -ForegroundColor White
    }
} else {
    Write-Host "  No deployment scripts found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the generated deployment script(s)" -ForegroundColor White
Write-Host "  2. Test in a non-production environment first" -ForegroundColor White
Write-Host "  3. Execute during maintenance window" -ForegroundColor White
Write-Host ""

Write-Success "All operations completed successfully!"
