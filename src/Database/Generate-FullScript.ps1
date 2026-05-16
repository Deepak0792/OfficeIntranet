#Requires -Version 5.1
<#
.SYNOPSIS
    Generates a full consolidated deployment SQL script containing all sprint changes.

.DESCRIPTION
    This script processes the _include.sql file and resolves all :r (include) statements
    to create a single, self-contained SQL deployment script that includes:
    - Base schema migration
    - All sprint changes (both active and commented)
    
    The output is a fully expanded SQL script ready for deployment.

.PARAMETER OutputPath
    Directory where the full script will be generated. Default: .\DeploymentScripts

.PARAMETER IncludeComments
    Include commented-out sprints in the output. Default: $true

.EXAMPLE
    .\Generate-FullScript.ps1
    Generates full deployment script with default settings

.EXAMPLE
    .\Generate-FullScript.ps1 -OutputPath ".\Release" -IncludeComments $false
    Generates full script excluding commented sprints
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\DeploymentScripts",
    
    [Parameter(Mandatory=$false)]
    [bool]$IncludeComments = $true
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

function Resolve-SqlIncludes {
    param(
        [string]$FilePath,
        [string]$BaseDirectory,
        [int]$Depth = 0,
        [bool]$IncludeComments = $true
    )

    if ($Depth -gt 10) {
        Write-Warning "Maximum include depth reached at: $FilePath"
        return ""
    }

    if (-not (Test-Path $FilePath)) {
        Write-Warning "File not found: $FilePath"
        return "-- WARNING: File not found: $FilePath"
    }

    $indent = "  " * $Depth
    Write-Info "$indent Processing: $FilePath"

    $lines = Get-Content $FilePath
    $result = New-Object System.Text.StringBuilder

    foreach ($line in $lines) {
        # Check for :r include statement - include raw content without any wrapping comments
        if ($line -match '^\s*:r\s+(.+)$') {
            $includePath = $matches[1].Trim()

            # Resolve relative path
            $fileDir = Split-Path $FilePath -Parent
            $resolvedPath = Join-Path $fileDir $includePath
            $resolvedPath = [System.IO.Path]::GetFullPath($resolvedPath)

            # Recursively resolve the included file - output raw content directly
            $includedContent = Resolve-SqlIncludes -FilePath $resolvedPath `
                                                    -BaseDirectory $BaseDirectory `
                                                    -Depth ($Depth + 1) `
                                                    -IncludeComments $IncludeComments

            [void]$result.AppendLine($includedContent)
        }
        # Check for commented :r statement - output exactly as-is
        elseif ($line -match '^\s*--\s*:r\s+(.+)$') {
            if ($IncludeComments) {
                [void]$result.AppendLine($line)
            }
        }
        else {
            [void]$result.AppendLine($line)
        }
    }

    return $result.ToString()
}

# ============================================================================
# Main Script
# ============================================================================

Write-Header "SdxCore Database - Full Consolidated Script Generation"

$startTime = Get-Date

# Validate source file
$includeFile = Join-Path $scriptRoot "_include.sql"
if (-not (Test-Path $includeFile)) {
    Write-Host "ERROR: _include.sql not found at: $includeFile" -ForegroundColor Red
    exit 1
}

Write-Info "Source file: $includeFile"
Write-Info "Include comments: $IncludeComments"

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Info "Created output directory: $OutputPath"
}

# Generate output file path (fixed name, no timestamp)
$outputFile = Join-Path $OutputPath "SdxCore.Database.Full.sql"

Write-Step "Generating full consolidated deployment script..."
Write-Info "  Output: $outputFile"

# Process the include file and resolve all includes
try {
    $fullScript = Resolve-SqlIncludes -FilePath $includeFile `
                                      -BaseDirectory $scriptRoot `
                                      -IncludeComments $IncludeComments

    # Add metadata header
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    $metadata = "/*
 * ============================================================================
 * FILE: SdxCore.Database.Full.sql
 * ============================================================================
 * Generated: $timestamp
 * Source: _include.sql (all includes resolved)
 * Database: SdxCore
 * ============================================================================
 */

"

    $finalScript = $metadata + $fullScript

    # Write to output file (overwrite if exists)
    $finalScript | Out-File -FilePath $outputFile -Encoding UTF8 -Force
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    $fileSize = [Math]::Round((Get-Item $outputFile).Length / 1KB, 2)
    $lineCount = ($finalScript -split "`n").Count
    
    Write-Success "Full consolidated script generated successfully!"
    Write-Info "  File: $outputFile"
    Write-Info "  Size: $fileSize KB"
    Write-Info "  Lines: $lineCount"
    Write-Info "  Duration: $($duration.ToString('mm\:ss'))"
    
} catch {
    Write-Host "ERROR: Failed to generate full script: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

# ============================================================================
# Summary
# ============================================================================

Write-Header "Full Script Generation Complete"

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Source File:          $includeFile" -ForegroundColor White
Write-Host "  Output File:          $outputFile" -ForegroundColor White
Write-Host "  Include Comments:     $IncludeComments" -ForegroundColor White
Write-Host "  File Size:            $fileSize KB" -ForegroundColor White
Write-Host "  Line Count:           $lineCount" -ForegroundColor White

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the generated script for accuracy" -ForegroundColor White
Write-Host "  2. Test in a non-production environment first" -ForegroundColor White
Write-Host "  3. Execute during maintenance window" -ForegroundColor White
Write-Host ""

Write-Success "Script generation completed successfully!"
