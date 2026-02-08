# Sync-TX15ToUsb-Mirror.ps1
# Mirrors EdgeTX configurations from digital twin to physical radio
# Mode: Exact copy - removes files not in source (destructive sync)

#Requires -Version 5.1

using namespace System.Collections.Generic

<#
.SYNOPSIS
    Mirrors EdgeTX configurations from repository to RadioMaster TX15
.DESCRIPTION
    Performs exact mirror synchronization of EdgeTX files from the digital twin
    (repository) to the physical transmitter. Copies new/modified files and
    removes files that don't exist in the source.
.WARNING
    This operation is DESTRUCTIVE - files not in the repository will be deleted from the radio!
.PARAMETER WhatIf
    Show what would be done without making changes
.PARAMETER Force
    Skip confirmation prompts (use with extreme caution)
.PARAMETER Verbose
    Enable verbose logging
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Import common functions
$commonModule = Join-Path $PSScriptRoot "Core\Common.psm1"
if (!(Test-Path $commonModule)) {
    Write-Error "Common module not found at $commonModule"
    exit 1
}
Import-Module $commonModule -Force

# Sync statistics
$syncStats = @{
    FilesCopied = 0
    FilesSkipped = 0
    FilesDeleted = 0
    Errors = 0
    StartTime = Get-Date
    EndTime = $null
    Duration = $null
}

function Main {
    try {
        Write-SyncLog -Message "Starting TX15 to USB MIRROR synchronization" -Level Warning -Context "Mirror"

        # Initialize environment
        if (!(Initialize-SyncEnvironment)) {
            throw "Failed to initialize sync environment"
        }

        # Check radio drive accessibility
        if (!(Test-RadioDrive)) {
            throw "Radio drive $($CONFIG.RadioDrive) is not accessible"
        }

        # Validate source directory
        if (!(Test-Path $CONFIG.EdgeTXPath)) {
            throw "Source directory not found: $($CONFIG.EdgeTXPath)"
        }

        # DANGER WARNING
        if (!$Force -and !$WhatIf) {
            Write-Host ""
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
            Write-Host "!!!                   DANGER WARNING                     !!!" -ForegroundColor Red
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
            Write-Host ""
            Write-Host "This MIRROR operation will DELETE files from your radio that" -ForegroundColor Red
            Write-Host "do not exist in the repository. This includes any custom" -ForegroundColor Red
            Write-Host "configurations, logs, or files you've added to the radio." -ForegroundColor Red
            Write-Host ""
            Write-Host "Make sure you have backed up any important data first!" -ForegroundColor Yellow
            Write-Host ""

            $backupChoice = Read-Host -Prompt "Have you backed up your radio data? (yes/no)"
            if ($backupChoice -notmatch "^(y|yes)$") {
                Write-SyncLog -Message "Mirror synchronization cancelled - backup not confirmed" -Level Info
                return
            }

            $confirmChoice = Read-Host -Prompt "Type 'MIRROR' to confirm destructive operation"
            if ($confirmChoice -ne "MIRROR") {
                Write-SyncLog -Message "Mirror synchronization cancelled - confirmation failed" -Level Info
                return
            }
        }

        # Perform mirror synchronization
        Mirror-ToRadio

        # Complete statistics
        $syncStats.EndTime = Get-Date
        $syncStats.Duration = $syncStats.EndTime - $syncStats.StartTime

        # Display summary
        $summary = Format-SyncSummary -Stats (Get-SyncStats -Stats $syncStats) -Operation "Repository to Radio (MIRROR)"
        Write-SyncLog -Message $summary -Level Warning -Context "Complete"

        # Exit with appropriate code
        if ($syncStats.Errors -gt 0) {
            exit 1
        }

    }
    catch {
        Write-SyncLog -Message "Mirror synchronization failed: $($_.Exception.Message)" -Level Error -Context "Error"
        exit 1
    }
}

<#
.SYNOPSIS
    Performs mirror synchronization from repository to radio
.DESCRIPTION
    Copies all files from EdgeTX directory to radio and removes extra files
#>
function Mirror-ToRadio {
    Write-SyncLog -Message "Beginning mirror synchronization" -Level Warning -Context "Mirror"

    # Define directories to mirror
    $syncDirs = @(
        "MODELS",
        "SCRIPTS",
        "RADIO"
    )

    foreach ($dir in $syncDirs) {
        $sourceDir = Join-Path $CONFIG.EdgeTXPath $dir
        $targetDir = Join-Path $CONFIG.RadioDrive $dir

        if (!(Test-Path $sourceDir)) {
            Write-SyncLog -Message "Source directory not found: $sourceDir" -Level Warning -Context "Mirror"
            continue
        }

        Write-SyncLog -Message "Mirroring directory: $dir" -Level Warning -Context "Mirror"

        # Get all source files
        $sourceFiles = Get-ChildItem -Path $sourceDir -Recurse -File
        $sourceRelativePaths = $sourceFiles | ForEach-Object {
            $_.FullName -replace [regex]::Escape($sourceDir), "" | TrimStart "\"
        }

        # Get all target files
        if (Test-Path $targetDir) {
            $targetFiles = Get-ChildItem -Path $targetDir -Recurse -File
            $targetRelativePaths = $targetFiles | ForEach-Object {
                $_.FullName -replace [regex]::Escape($targetDir), "" | TrimStart "\"
            }
        } else {
            $targetRelativePaths = @()
        }

        # Find files to delete (exist in target but not in source)
        $filesToDelete = $targetRelativePaths | Where-Object { $_ -notin $sourceRelativePaths }

        # Delete extra files
        foreach ($fileToDelete in $filesToDelete) {
            $fullPathToDelete = Join-Path $targetDir $fileToDelete
            try {
                if ($PSCmdlet.ShouldProcess($fullPathToDelete, "Delete (mirror operation)")) {
                    Remove-Item -Path $fullPathToDelete -Force
                    Write-SyncLog -Message "Deleted: $fileToDelete" -Level Info -Context "Mirror"
                    $syncStats.FilesDeleted++
                }
            }
            catch {
                Write-SyncLog -Message "Failed to delete $fullPathToDelete`: $($_.Exception.Message)" -Level Error -Context "Mirror"
                $syncStats.Errors++
            }
        }

        # Copy/update files from source
        foreach ($sourceFile in $sourceFiles) {
            try {
                $relativePath = $sourceFile.FullName -replace [regex]::Escape($sourceDir), "" | TrimStart "\"
                $targetFile = Join-Path $targetDir $relativePath

                # Check if file needs updating
                $needsUpdate = $true
                if (Test-Path $targetFile) {
                    $sourceHash = Get-FileHash -Path $sourceFile.FullName
                    $targetHash = Get-FileHash -Path $targetFile
                    $needsUpdate = $sourceHash -ne $targetHash
                }

                if ($needsUpdate) {
                    if ($PSCmdlet.ShouldProcess($targetFile, "Copy (mirror from $($sourceFile.FullName))")) {
                        if (Copy-FileSafe -Source $sourceFile.FullName -Destination $targetFile -Force) {
                            Write-SyncLog -Message "Copied: $relativePath" -Level Info -Context "Mirror"
                            $syncStats.FilesCopied++
                        } else {
                            $syncStats.Errors++
                        }
                    }
                } else {
                    Write-SyncLog -Message "Unchanged: $relativePath" -Level Debug -Context "Mirror"
                    $syncStats.FilesSkipped++
                }

            }
            catch {
                Write-SyncLog -Message "Error processing $($sourceFile.FullName): $($_.Exception.Message)" -Level Error -Context "Mirror"
                $syncStats.Errors++
            }
        }
    }

    Write-SyncLog -Message "Mirror synchronization completed" -Level Warning -Context "Mirror"
}

# Execute main function
Main