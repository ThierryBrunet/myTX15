# Common Functions Module for RC Transmitter Synchronization
# Provides shared utilities for all sync operations

#Requires -Version 5.1

using namespace System.Collections.Generic

<#
.SYNOPSIS
    Common utilities for RC transmitter synchronization scripts
.DESCRIPTION
    This module contains shared functions used across all synchronization operations
    including logging, file operations, and configuration management.
#>

# Configuration constants
$script:CONFIG = @{
    RadioDrive = "d:"
    RepoRoot = $PSScriptRoot | Split-Path -Parent
    EdgeTXPath = Join-Path $PSScriptRoot "..\EdgeTX" -Resolve
    LogPath = Join-Path $PSScriptRoot "..\EdgeTX\LOGS\sync-logs" -Resolve
    MaxLogSize = 10MB
    SyncTimeout = 300  # 5 minutes
}

<#
.SYNOPSIS
    Initializes the synchronization environment
.DESCRIPTION
    Sets up logging, validates paths, and prepares for sync operations
.OUTPUTS
    [bool] Success status
#>
function Initialize-SyncEnvironment {
    [CmdletBinding()]
    param()

    try {
        # Create log directory if it doesn't exist
        if (!(Test-Path $script:CONFIG.LogPath)) {
            New-Item -ItemType Directory -Path $script:CONFIG.LogPath -Force | Out-Null
        }

        # Validate critical paths
        $pathsToCheck = @(
            $script:CONFIG.RepoRoot,
            $script:CONFIG.EdgeTXPath
        )

        foreach ($path in $pathsToCheck) {
            if (!(Test-Path $path)) {
                throw "Required path not found: $path"
            }
        }

        Write-SyncLog -Message "Sync environment initialized successfully" -Level Info
        return $true
    }
    catch {
        Write-SyncLog -Message "Failed to initialize sync environment: $($_.Exception.Message)" -Level Error
        return $false
    }
}

<#
.SYNOPSIS
    Writes a log entry to the sync log
.DESCRIPTION
    Logs messages with timestamp, level, and context information
.PARAMETER Message
    The log message to write
.PARAMETER Level
    Log level: Debug, Info, Warning, Error
.PARAMETER Context
    Optional context information for the log entry
#>
function Write-SyncLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false)]
        [string]$Context = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level]"

    if ($Context) {
        $logEntry += " [$Context]"
    }

    $logEntry += " $Message"

    # Write to console with color coding
    switch ($Level) {
        "Debug" { Write-Host $logEntry -ForegroundColor Gray }
        "Info" { Write-Host $logEntry -ForegroundColor White }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
        "Error" { Write-Host $logEntry -ForegroundColor Red }
    }

    # Write to log file
    try {
        $logFile = Join-Path $script:CONFIG.LogPath "sync-$(Get-Date -Format 'yyyyMMdd').log"
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8

        # Rotate log if too large
        if ((Get-Item $logFile).Length -gt $script:CONFIG.MaxLogSize) {
            $backupLog = $logFile -replace '\.log$', "-$(Get-Date -Format 'HHmmss').log"
            Move-Item $logFile $backupLog
        }
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Validates that the radio drive is accessible
.DESCRIPTION
    Checks if the configured radio drive exists and is ready for operations
.OUTPUTS
    [bool] Drive accessibility status
#>
function Test-RadioDrive {
    [CmdletBinding()]
    param()

    try {
        $drive = Get-PSDrive -Name ($script:CONFIG.RadioDrive -replace ':', '') -ErrorAction Stop
        if ($drive) {
            Write-SyncLog -Message "Radio drive $($script:CONFIG.RadioDrive) is accessible" -Level Info -Context "DriveCheck"
            return $true
        }
    }
    catch {
        Write-SyncLog -Message "Radio drive $($script:CONFIG.RadioDrive) is not accessible: $($_.Exception.Message)" -Level Error -Context "DriveCheck"
        return $false
    }
}

<#
.SYNOPSIS
    Gets file hash for change detection
.DESCRIPTION
    Calculates SHA256 hash of a file for comparison operations
.PARAMETER Path
    Path to the file to hash
.OUTPUTS
    [string] SHA256 hash or empty string on error
#>
function Get-FileHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        if (Test-Path $Path -PathType Leaf) {
            $hash = Get-FileHash -Path $Path -Algorithm SHA256
            return $hash.Hash
        }
    }
    catch {
        Write-SyncLog -Message "Failed to hash file $Path`: $($_.Exception.Message)" -Level Warning -Context "Hash"
    }

    return ""
}

<#
.SYNOPSIS
    Safely copies a file with error handling
.DESCRIPTION
    Copies a file with comprehensive error handling and logging
.PARAMETER Source
    Source file path
.PARAMETER Destination
    Destination file path
.PARAMETER Force
    Overwrite existing files
.OUTPUTS
    [bool] Copy success status
#>
function Copy-FileSafe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    try {
        $destDir = Split-Path $Destination -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        Copy-Item -Path $Source -Destination $Destination -Force:$Force -ErrorAction Stop
        Write-SyncLog -Message "Copied $Source to $Destination" -Level Debug -Context "FileCopy"
        return $true
    }
    catch {
        Write-SyncLog -Message "Failed to copy $Source to $Destination`: $($_.Exception.Message)" -Level Error -Context "FileCopy"
        return $false
    }
}

<#
.SYNOPSIS
    Gets synchronization statistics
.DESCRIPTION
    Collects and returns statistics about sync operations
.PARAMETER Stats
    Hashtable containing sync counters
.OUTPUTS
    [hashtable] Formatted statistics
#>
function Get-SyncStats {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Stats
    )

    return @{
        FilesCopied = $Stats.FilesCopied
        FilesSkipped = $Stats.FilesSkipped
        FilesDeleted = $Stats.FilesDeleted
        Errors = $Stats.Errors
        Duration = $Stats.Duration
        StartTime = $Stats.StartTime
        EndTime = $Stats.EndTime
    }
}

<#
.SYNOPSIS
    Formats synchronization summary
.DESCRIPTION
    Creates a formatted summary of sync operation results
.PARAMETER Stats
    Synchronization statistics
.PARAMETER Operation
    Type of sync operation performed
.OUTPUTS
    [string] Formatted summary
#>
function Format-SyncSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Stats,

        [Parameter(Mandatory = $true)]
        [string]$Operation
    )

    $summary = @"
=== $Operation Synchronization Summary ===
Start Time: $($Stats.StartTime)
End Time: $($Stats.EndTime)
Duration: $($Stats.Duration)

Files Copied: $($Stats.FilesCopied)
Files Skipped: $($Stats.FilesSkipped)
Files Deleted: $($Stats.FilesDeleted)
Errors: $($Stats.Errors)

Status: $(if ($Stats.Errors -eq 0) { "SUCCESS" } else { "COMPLETED WITH ERRORS" })
"@

    return $summary
}

<#
.SYNOPSIS
    Validates YAML file syntax
.DESCRIPTION
    Performs basic validation of YAML configuration files
.PARAMETER Path
    Path to YAML file to validate
.OUTPUTS
    [bool] Validation success status
#>
function Test-YamlFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        if (!(Test-Path $Path)) {
            Write-SyncLog -Message "YAML file not found: $Path" -Level Warning -Context "Validation"
            return $false
        }

        $content = Get-Content $Path -Raw -Encoding UTF8

        # Basic YAML validation - check for common syntax errors
        $lines = $content -split "`n"
        $indentStack = [Stack[int]]::new()

        for ($i = 0; $i -lt $lines.Length; $i++) {
            $line = $lines[$i].TrimEnd()

            # Skip empty lines and comments
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
                continue
            }

            # Check for basic YAML structure
            $indent = $line.Length - $line.TrimStart().Length

            # Very basic validation - could be enhanced with proper YAML parser
            if ($line.Contains(":") -and !$line.Contains(":")) {
                Write-SyncLog -Message "Potential YAML syntax error in $Path at line $($i + 1): $line" -Level Warning -Context "Validation"
            }
        }

        Write-SyncLog -Message "YAML validation passed for $Path" -Level Debug -Context "Validation"
        return $true
    }
    catch {
        Write-SyncLog -Message "YAML validation failed for $Path`: $($_.Exception.Message)" -Level Error -Context "Validation"
        return $false
    }
}

<#
.SYNOPSIS
    Gets the relative path from repository root
.DESCRIPTION
    Converts an absolute path to a relative path from the repository root
.PARAMETER Path
    Absolute path to convert
.OUTPUTS
    [string] Relative path
#>
function Get-RelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $resolvedPath = Resolve-Path $Path
        $relativePath = $resolvedPath.Path -replace [regex]::Escape($script:CONFIG.RepoRoot), ""
        return $relativePath.TrimStart("\")
    }
    catch {
        Write-SyncLog -Message "Failed to get relative path for $Path`: $($_.Exception.Message)" -Level Warning -Context "Path"
        return $Path
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Initialize-SyncEnvironment',
    'Write-SyncLog',
    'Test-RadioDrive',
    'Get-FileHash',
    'Copy-FileSafe',
    'Get-SyncStats',
    'Format-SyncSummary',
    'Test-YamlFile',
    'Get-RelativePath'
)

# Export configuration for use by other modules
Export-ModuleMember -Variable 'CONFIG'