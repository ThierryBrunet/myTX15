#Requires -Version 5.1
<#
.SYNOPSIS
    Synchronizes RadioMaster TX15 EdgeTX configuration between SD card and Git repository.

.DESCRIPTION
    Manages bidirectional sync with four modes: SyncToRadio, SyncFromRadio, MirrorToRadio, MirrorFromRadio.
    Implements safety checks, backups, and validation for RC radio configuration management.

.PARAMETER Mode
    Sync mode: SyncToRadio, SyncFromRadio, MirrorToRadio, MirrorFromRadio

.PARAMETER RadioPath
    Path to TX15 SD card (default: D:\)

.PARAMETER GitPath
    Path to Git repository (default: C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX)

.PARAMETER BackupPath
    Path for backups (default: C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\Backups)

.PARAMETER Force
    Skip confirmation for destructive operations (Mirror modes)

.PARAMETER Verbose
    Show detailed progress

.EXAMPLE
    .\Sync-TX15Config.ps1 -Mode SyncToRadio -Verbose
    Deploy Git configs to radio safely

.EXAMPLE
    .\Sync-TX15Config.ps1 -Mode MirrorFromRadio -Force
    Force radio state to Git (destructive)

.NOTES
    Version: 1.0.0
    Author: Cursor AI Assistant
    Date: 2025-02-07
    WBS Reference: 02.01.01
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("SyncToRadio", "SyncFromRadio", "MirrorToRadio", "MirrorFromRadio")]
    [string]$Mode,

    [string]$RadioPath = "D:\",

    [string]$GitPath = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX",

    [string]$BackupPath = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\Backups",

    [switch]$Force,

    [string]$Filter = "*",

    [switch]$CreateGitCommit,

    [string]$CommitMessage = ""
)

# 01.00.00 - Initialization

$ErrorActionPreference = "Stop"
$script:Version = "1.0.0"
$script:StartTime = Get-Date

# 01.01.00 - Configuration
$Config = @{
    SyncFolders = @(
        "MODELS",
        "RADIO",
        "SCRIPTS\Tools",
        "SOUNDS\en",
        "SOUNDS\system",
        "IMAGES"
    )

    ExcludePatterns = @(
        "*.log",
        "*.tmp",
        "*.bak",
        "desktop.ini",
        "Thumbs.db",
        "System Volume Information",
        ".*"
    )

    CriticalFiles = @(
        "RADIO\radio.yml",
        "RADIO\models.txt"
    )
}

# 02.00.00 - Logging Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )

    $timestamp = Get-Date -Format "HH:mm:ss"
    $colorMap = @{
        "Info" = "White"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Success" = "Green"
    }

    Write-Host "[$timestamp] " -NoNewline -ForegroundColor Gray
    Write-Host $Message -ForegroundColor $colorMap[$Level]
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
}

# 03.00.00 - Validation Functions

function Test-Environment {
    Write-Section "03.01.00 - Environment Validation"

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or higher required"
    }
    Write-Log "PowerShell version: $($PSVersionTable.PSVersion)" "Success"

    # Validate Radio Path
    if (-not (Test-Path $RadioPath)) {
        throw "Radio SD card not found at: $RadioPath"
    }
    Write-Log "Radio path validated: $RadioPath" "Success"

    # Validate Git Path
    if (-not (Test-Path $GitPath)) {
        throw "Git repository not found at: $GitPath"
    }
    Write-Log "Git path validated: $GitPath" "Success"

    # Check for EdgeTX Companion running
    $companion = Get-Process -Name "companion" -ErrorAction SilentlyContinue
    if ($companion) {
        Write-Log "WARNING: EdgeTX Companion is running. Close it to prevent conflicts." "Warning"
        if (-not $Force) {
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y") { exit }
        }
    }

    # Validate critical folders exist on radio
    $modelsPath = Join-Path $RadioPath "MODELS"
    if (-not (Test-Path $modelsPath)) {
        throw "MODELS folder not found on SD card. Is this a valid EdgeTX SD card?"
    }

    # Check disk space
    $drive = Get-Item $RadioPath | Select-Object -ExpandProperty PSParentPath | Split-Path -Leaf
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='${drive}'"
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    Write-Log "SD Card free space: $freeSpaceGB GB" "Info"

    return $true
}

function Test-FileValid {
    param([string]$FilePath)

    # Skip excluded patterns
    $fileName = Split-Path $FilePath -Leaf
    foreach ($pattern in $Config.ExcludePatterns) {
        if ($fileName -like $pattern) { return $false }
    }

    return $true
}

# 04.00.00 - Backup Functions

function New-Backup {
    param(
        [string]$SourcePath,
        [string]$BackupType
    )

    Write-Section "04.01.00 - Creating Backup"

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "TX15_${BackupType}_${timestamp}"
    $backupDir = Join-Path $BackupPath $backupName

    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }

    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    Write-Log "Creating backup at: $backupDir"

    # Backup critical folders
    foreach ($folder in $Config.SyncFolders) {
        $source = Join-Path $SourcePath $folder
        $dest = Join-Path $backupDir $folder

        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Backed up: $folder" "Success"
        }
    }

    # Create backup manifest
    $manifest = @{
        Timestamp = Get-Date -Format "o"
        Source = $SourcePath
        Type = $BackupType
        Mode = $Mode
        Version = $script:Version
    }
    $manifest | ConvertTo-Json | Out-File (Join-Path $backupDir "manifest.json")

    Write-Log "Backup completed: $backupName" "Success"
    return $backupDir
}

# 05.00.00 - Core Sync Functions

function Get-FileHashSafe {
    param([string]$Path)

    if (-not (Test-Path $Path)) { return $null }

    try {
        return (Get-FileHash -Path $Path -Algorithm MD5).Hash
    } catch {
        return $null
    }
}

function Sync-Folder {
    param(
        [string]$Source,
        [string]$Destination,
        [bool]$DeleteMissing = $false,
        [string]$Filter = "*"
    )

    $stats = @{
        Copied = 0
        Updated = 0
        Deleted = 0
        Skipped = 0
        Errors = 0
    }

    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    # Get all source files
    $sourceFiles = Get-ChildItem -Path $Source -Recurse -File -Filter $Filter | 
        Where-Object { Test-FileValid $_.FullName }

    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Substring($Source.Length).TrimStart("\", "/")
        $destPath = Join-Path $Destination $relativePath
        $destDir = Split-Path $destPath -Parent

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $sourceHash = Get-FileHashSafe $file.FullName
        $destHash = Get-FileHashSafe $destPath

        if ($destHash -eq $null) {
            # New file
            if ($PSCmdlet.ShouldProcess($destPath, "Copy new file")) {
                try {
                    Copy-Item -Path $file.FullName -Destination $destPath -Force
                    $stats.Copied++
                    Write-Log "Copied: $relativePath" "Success"
                } catch {
                    $stats.Errors++
                    Write-Log "Error copying $relativePath`: $_" "Error"
                }
            }
        } elseif ($sourceHash -ne $destHash) {
            # Modified file
            if ($PSCmdlet.ShouldProcess($destPath, "Update file")) {
                try {
                    Copy-Item -Path $file.FullName -Destination $destPath -Force
                    $stats.Updated++
                    Write-Log "Updated: $relativePath" "Success"
                } catch {
                    $stats.Errors++
                    Write-Log "Error updating $relativePath`: $_" "Error"
                }
            }
        } else {
            $stats.Skipped++
            Write-Verbose "Skipped (identical): $relativePath"
        }
    }

    # Handle deletions for mirror mode
    if ($DeleteMissing) {
        $destFiles = Get-ChildItem -Path $Destination -Recurse -File | 
            Where-Object { Test-FileValid $_.FullName }

        foreach ($file in $destFiles) {
            $relativePath = $file.FullName.Substring($Destination.Length).TrimStart("\", "/")
            $sourcePath = Join-Path $Source $relativePath

            if (-not (Test-Path $sourcePath)) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Delete file")) {
                    try {
                        Remove-Item -Path $file.FullName -Force
                        $stats.Deleted++
                        Write-Log "Deleted: $relativePath" "Warning"
                    } catch {
                        $stats.Errors++
                        Write-Log "Error deleting $relativePath`: $_" "Error"
                    }
                }
            }
        }
    }

    return $stats
}

# 06.00.00 - Validation Post-Sync

function Test-PostSync {
    Write-Section "06.01.00 - Post-Sync Validation"

    $errors = @()

    # Check critical files exist
    foreach ($critical in $Config.CriticalFiles) {
        $path = Join-Path $RadioPath $critical
        if (-not (Test-Path $path)) {
            $errors += "Missing critical file: $critical"
        }
    }

    # Validate YAML files
    $yamlFiles = Get-ChildItem -Path (Join-Path $RadioPath "MODELS") -Filter "*.yml" -ErrorAction SilentlyContinue
    foreach ($file in $yamlFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match "`t") {
            $errors += "$($file.Name): Contains tabs (YAML requires spaces)"
        }
    }

    # Count models
    $modelCount = $yamlFiles.Count
    Write-Log "Models on radio: $modelCount" "Info"

    if ($errors.Count -gt 0) {
        Write-Log "Validation warnings:" "Warning"
        $errors | ForEach-Object { Write-Log "  - $_" "Warning" }
    } else {
        Write-Log "All validations passed" "Success"
    }

    return $errors.Count -eq 0
}

# 07.00.00 - Git Integration

function Invoke-GitCommit {
    param([string]$Message)

    Write-Section "07.01.00 - Git Commit"

    try {
        Push-Location $GitPath

        # Check if git repo
        if (-not (Test-Path ".git")) {
            Write-Log "Not a git repository, skipping commit" "Warning"
            return
        }

        # Add all changes
        $null = git add .

        # Check if there are changes to commit
        $status = git status --porcelain
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Log "No changes to commit" "Info"
            return
        }

        # Commit
        $commitMsg = if ($Message) { $Message } else { "TX15 Sync - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
        $null = git commit -m "$commitMsg"

        Write-Log "Committed changes: $commitMsg" "Success"

    } catch {
        Write-Log "Git commit failed: $_" "Error"
    } finally {
        Pop-Location
    }
}

# 08.00.00 - Main Execution

function Start-Sync {
    Write-Section "01.00.00 - TX15 Configuration Sync"
    Write-Log "Mode: $Mode"
    Write-Log "Script Version: $script:Version"
    Write-Log "Start Time: $script:StartTime"

    # Validate environment
    Test-Environment

    # Determine direction and options
    $source = $null
    $dest = $null
    $deleteMissing = $false
    $backupSource = $null
    $backupType = $null

    switch ($Mode) {
        "SyncToRadio" {
            $source = $GitPath
            $dest = $RadioPath
            $deleteMissing = $false
            $backupSource = $RadioPath
            $backupType = "PreSyncToRadio"
            Write-Log "Direction: Git -> Radio (Safe, no deletions)" "Info"
        }
        "SyncFromRadio" {
            $source = $RadioPath
            $dest = $GitPath
            $deleteMissing = $false
            $backupSource = $GitPath
            $backupType = "PreSyncFromRadio"
            Write-Log "Direction: Radio -> Git (Safe, no deletions)" "Info"
        }
        "MirrorToRadio" {
            $source = $GitPath
            $dest = $RadioPath
            $deleteMissing = $true
            $backupSource = $RadioPath
            $backupType = "PreMirrorToRadio"
            Write-Log "Direction: Git -> Radio (DESTRUCTIVE, deletes extra files)" "Warning"

            if (-not $Force) {
                $confirm = Read-Host "WARNING: This will DELETE files on the radio not in Git. Type 'MIRROR' to confirm"
                if ($confirm -ne "MIRROR") {
                    Write-Log "Operation cancelled by user" "Warning"
                    exit
                }
            }
        }
        "MirrorFromRadio" {
            $source = $RadioPath
            $dest = $GitPath
            $deleteMissing = $true
            $backupSource = $GitPath
            $backupType = "PreMirrorFromRadio"
            Write-Log "Direction: Radio -> Git (DESTRUCTIVE, deletes extra files)" "Warning"

            if (-not $Force) {
                $confirm = Read-Host "WARNING: This will DELETE files in Git not on Radio. Type 'MIRROR' to confirm"
                if ($confirm -ne "MIRROR") {
                    Write-Log "Operation cancelled by user" "Warning"
                    exit
                }
            }
        }
    }

    # Create backup
    $backupDir = New-Backup -SourcePath $backupSource -BackupType $backupType

    # Perform sync for each folder
    Write-Section "05.01.00 - Synchronizing Folders"

    $totalStats = @{
        Copied = 0
        Updated = 0
        Deleted = 0
        Skipped = 0
        Errors = 0
    }

    foreach ($folder in $Config.SyncFolders) {
        $srcFolder = Join-Path $source $folder
        $dstFolder = Join-Path $dest $folder

        if (Test-Path $srcFolder) {
            Write-Log "Processing: $folder"
            $stats = Sync-Folder -Source $srcFolder -Destination $dstFolder -DeleteMissing $deleteMissing -Filter $Filter

            $totalStats.Copied += $stats.Copied
            $totalStats.Updated += $stats.Updated
            $totalStats.Deleted += $stats.Deleted
            $totalStats.Skipped += $stats.Skipped
            $totalStats.Errors += $stats.Errors
        } else {
            Write-Log "Source folder not found: $folder" "Warning"
        }
    }

    # Display summary
    Write-Section "05.02.00 - Sync Summary"
    Write-Log "Files Copied: $($totalStats.Copied)" "Success"
    Write-Log "Files Updated: $($totalStats.Updated)" "Success"
    Write-Log "Files Skipped: $($totalStats.Skipped)" "Info"
    if ($deleteMissing) {
        Write-Log "Files Deleted: $($totalStats.Deleted)" "Warning"
    }
    if ($totalStats.Errors -gt 0) {
        Write-Log "Errors: $($totalStats.Errors)" "Error"
    }

    # Post-sync validation
    Test-PostSync

    # Git commit if requested
    if ($CreateGitCommit -and ($Mode -eq "SyncFromRadio" -or $Mode -eq "MirrorFromRadio")) {
        Invoke-GitCommit -Message $CommitMessage
    }

    # Final summary
    $duration = (Get-Date) - $script:StartTime
    Write-Section "08.01.00 - Completed"
    Write-Log "Duration: $($duration.ToString('mm\:ss'))"
    Write-Log "Backup location: $backupDir" "Info"
    Write-Log "Operation completed successfully" "Success"
}

# 09.00.00 - Entry Point

try {
    Start-Sync
} catch {
    Write-Log "FATAL ERROR: $_" "Error"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "Error"
    exit 1
}
