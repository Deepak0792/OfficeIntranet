#Requires -Version 5.1
<#
.SYNOPSIS
    Generates a single delta deployment script containing all sprint changes.

.DESCRIPTION
    This script:
    1. First generates the full script (SdxCore.Database.Full.sql) using Generate-FullScript.ps1
    2. Then extracts content between --Start of Delta Sprint and --End of Delta Sprint
       markers from the generated full script
    3. Creates the delta deployment script from that extracted content

    The output file is always named SdxCore.Database.Delta.sql and will
    be overwritten if it already exists.

.PARAMETER OutputPath
    Directory where the delta script will be generated. Default: .\DeploymentScripts

.PARAMETER IncludeBase
    Include the Base migration in the delta script. Default: $false

.PARAMETER SkipFullScript
    Skip generating the full script first. Use existing SdxCore.Database.Full.sql

.EXAMPLE
    .\Generate-DeltaScript.ps1
    Generates full script first, then delta from it

.EXAMPLE
    .\Generate-DeltaScript.ps1 -IncludeBase
    Generates delta script including Base migration

.EXAMPLE
    .\Generate-DeltaScript.ps1 -OutputPath ".\Release"
    Generates delta script in custom directory

.EXAMPLE
    .\Generate-DeltaScript.ps1 -SkipFullScript
    Generate delta from existing SdxCore.Database.Full.sql
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\DeploymentScripts",

    [Parameter(Mandatory=$false)]
    [switch]$IncludeBase,

    [Parameter(Mandatory=$false)]
    [switch]$SkipFullScript
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

Write-Header "SdxCore Database - Delta Script Generation"

$startTime = Get-Date

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Info "Created output directory: $OutputPath"
}

# Output file path (fixed name, no timestamp)
$outputFile = Join-Path $OutputPath "SdxCore.Database.Delta.sql"
$fullScriptFile = Join-Path $OutputPath "SdxCore.Database.Full.sql"

# ============================================================================
# Step 1: Generate Full Script (if not skipped)
# ============================================================================

if (-not $SkipFullScript) {
    Write-Step "Generating full script first..."

    $fullScriptGenerator = Join-Path $scriptRoot "Generate-FullScript.ps1"

    if (-not (Test-Path $fullScriptGenerator)) {
        Write-Host "ERROR: Generate-FullScript.ps1 not found at: $fullScriptGenerator" -ForegroundColor Red
        exit 1
    }

    Write-Info "Calling Generate-FullScript.ps1..."

    try {
        & $fullScriptGenerator -OutputPath $OutputPath

        if (-not (Test-Path $fullScriptFile)) {
            throw "Full script was not generated at: $fullScriptFile"
        }

        Write-Success "Full script generated: $fullScriptFile"
    } catch {
        Write-Host "ERROR: Failed to generate full script: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Info "Skipping full script generation (using existing file)"

    if (-not (Test-Path $fullScriptFile)) {
        Write-Host "ERROR: Full script not found at: $fullScriptFile. Run without -SkipFullScript first." -ForegroundColor Red
        exit 1
    }
}

# ============================================================================
# Step 2: Extract Delta Content from Full Script
# ============================================================================

Write-Step "Extracting delta content from SdxCore.Database.Full.sql..."

try {
    $lines = Get-Content $fullScriptFile

    # Extract ALL content between delta markers (raw content exactly as-is, no filtering)
    Write-Info "  Extracting all content between delta markers..."
    $deltaContent = @()
    $inDeltaBlock = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '--Start of Delta Sprint') {
            $inDeltaBlock = $true
            continue
        }

        if ($line -match '--End of Delta Sprint') {
            $inDeltaBlock = $false
            continue
        }

        # Include everything exactly as-is (both active and commented sprints)
        if ($inDeltaBlock) {
            $deltaContent += $line
        }
    }

    Write-Info "  Extracted $($deltaContent.Count) lines"

    if ($deltaContent.Count -eq 0) {
        Write-Host "WARNING: No delta content found between markers" -ForegroundColor Yellow
        Write-Host "Make sure your _include.sql has --Start of Delta Sprint and --End of Delta Sprint markers" -ForegroundColor Yellow
        exit 1
    }

    # Build delta script - output raw content exactly as-is
    Write-Step "Building delta deployment script..."

    $sb = New-Object System.Text.StringBuilder

    # Add metadata header
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    [void]$sb.AppendLine("/*")
    [void]$sb.AppendLine(" * ============================================================================")
    [void]$sb.AppendLine(" * FILE: SdxCore.Database.Delta.sql")
    [void]$sb.AppendLine(" * ============================================================================ ")
    [void]$sb.AppendLine(" * Generated: $timestamp")
    [void]$sb.AppendLine(" * Source: SdxCore.Database.Full.sql (content between delta markers)")
    [void]$sb.AppendLine(" * Database: SdxCore")
    [void]$sb.AppendLine(" * ============================================================================")
    [void]$sb.AppendLine(" */")
    [void]$sb.AppendLine("")

    # Output raw delta content
    foreach ($line in $deltaContent) {
        [void]$sb.AppendLine($line)
    }

    # Write to output file (overwrite if exists)
    $sb.ToString() | Out-File -FilePath $outputFile -Encoding UTF8 -Force
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    $fileSize = [Math]::Round((Get-Item $outputFile).Length / 1KB, 2)
    $lineCount = ($sb.ToString() -split "`n").Count
    
    Write-Success "Delta script generated successfully!"
    Write-Info "  File: $outputFile"
    Write-Info ('  Size: ' + $fileSize + ' KB')
    Write-Info "  Lines: $lineCount"
    Write-Info "  Duration: $($duration.ToString('mm\:ss'))"
    
} catch {
    Write-Host "ERROR: Failed to generate delta script: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

# ============================================================================
# Summary
# ============================================================================

Write-Header "Delta Script Generation Complete"

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Full Script Source:   $fullScriptFile" -ForegroundColor White
Write-Host "  Delta Output File:    $outputFile" -ForegroundColor White
Write-Host "  Skip Full Script:     $SkipFullScript" -ForegroundColor White
Write-Host "  File Size:            $fileSize KB" -ForegroundColor White
Write-Host "  Line Count:           $lineCount" -ForegroundColor White

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the generated delta script" -ForegroundColor White
Write-Host "  2. Test in a non-production environment first" -ForegroundColor White
Write-Host "  3. Execute during maintenance window" -ForegroundColor White
Write-Host ""

Write-Success "Script generation completed successfully!"
