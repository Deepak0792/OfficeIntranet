# SdxCore Database - Deployment Script Generation

This directory contains PowerShell scripts for generating SQL deployment scripts for the SdxCore database.

## Scripts

| Script | Description |
|--------|-------------|
| `Build-All.ps1` | Master script that generates both Full and Delta SQL scripts |
| `Generate-FullScript.ps1` | Generates the complete deployment script (all schema + data) |
| `Generate-DeltaScript.ps1` | Generates incremental delta script (only sprint changes) |

## Prerequisites

- PowerShell 5.1 or later
- SQL Server (optional - only needed for full DACPAC build)
- Visual Studio/SSDT (optional - only needed for DACPAC build)

## Usage

### Option 1: Build-All.ps1 (Recommended)

Generates both Full and Delta scripts in one command:

```powershell
.\Build-All.ps1
```

With custom settings:

```powershell
.\Build-All.ps1 -TargetServer "prod-server" -TargetDatabase "SdxCore_Prod" -OutputPath ".\Release"
```

**Parameters:**
- `-Configuration` - Build config (Debug/Release). Default: Release
- `-TargetServer` - SQL Server name. Default: localhost
- `-TargetDatabase` - Database name. Default: SdxCore
- `-OutputPath` - Output directory. Default: .\DeploymentScripts
- `-SkipBuild` - Skip DACPAC build (use existing)
- `-SkipFullScript` - Skip full script generation
- `-SkipDeltaScripts` - Skip delta script generation

### Option 2: Generate-FullScript.ps1

Generates the complete deployment script:

```powershell
.\Generate-FullScript.ps1
```

With custom output path:

```powershell
.\Generate-FullScript.ps1 -OutputPath ".\CustomOutput"
```

**Parameters:**
- `-OutputPath` - Output directory. Default: .\DeploymentScripts
- `-IncludeComments` - Include commented sprints. Default: $true

### Option 3: Generate-DeltaScript.ps1

Generates the incremental delta script:

```powershell
.\Generate-DeltaScript.ps1
```

With existing full script:

```powershell
.\Generate-DeltaScript.ps1 -SkipFullScript
```

**Parameters:**
- `-OutputPath` - Output directory. Default: .\DeploymentScripts
- `-IncludeBase` - Include Base migration in delta. Default: $false
- `-SkipFullScript` - Use existing Full.sql instead of regenerating

## Output Files

After execution, the following files are generated in the `DeploymentScripts` folder:

| File | Description | Size |
|------|-------------|------|
| `SdxCore.Database.Full.sql` | Complete deployment script with all schema and data | ~919 KB |
| `SdxCore.Database.Delta.sql` | Incremental delta script (sprint changes only) | ~2 KB |

## Metadata

Each generated SQL file includes a metadata header:

```sql
/*
 * ============================================================================
 * FILE: SdxCore.Database.Full.sql
 * ============================================================================
 * Generated: 2026-05-16 17:23:23 UTC
 * Source: _include.sql (all includes resolved)
 * Database: SdxCore
 * ============================================================================
 */
```

## Project Structure

```
src/Database/
├── _include.sql              # Main entry point
├── Build-All.ps1              # Master build script
├── Generate-FullScript.ps1    # Full script generator
├── Generate-DeltaScript.ps1  # Delta script generator
├── DeploymentScripts/        # Output directory
│   ├── SdxCore.Database.Full.sql
│   └── SdxCore.Database.Delta.sql
├── Base/                     # Base schema migration
├── Sprint01/                 # Sprint 01 incremental changes
└── Sprint02/                 # Sprint 02 incremental changes (commented)
```

## Examples

### Generate both scripts with default settings

```powershell
```Use this command to build database
cd d:\Office\SdxCore\src\Database
.\Build-All.ps1 -SkipBuild
```

### Generate only full script

```powershell
.\Generate-FullScript.ps1 -OutputPath ".\MyOutput"
```

### Generate delta from existing full script

```powershell
.\Generate-DeltaScript.ps1 -SkipFullScript
```

## Notes

- The `-SkipBuild` flag is recommended if MSBuild/Visual Studio is not installed, as the full DACPAC build is optional for SQL script generation.
- Delta script extracts content between `--Start of Delta Sprint` and `--End of Delta Sprint` markers from the full script.
- Both active and commented sprints are included in the output.