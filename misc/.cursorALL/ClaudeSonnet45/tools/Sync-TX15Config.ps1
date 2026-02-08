<#
.SYNOPSIS
    RadioMaster TX15 Configuration Synchronization Tool

.DESCRIPTION
    Synchronizes EdgeTX configurations between TX15 SD card and Git repository.
    Implements four sync modes: SyncToRadio, SyncFromRadio, MirrorToRadio, MirrorFromRadio
    
    WBS: 03.00.00 - Configuration Synchronization

.PARAMETER Mode
    Sync mode: SyncToRadio, SyncFromRadio, MirrorToRadio, MirrorFromRadio

.PARAMETER RadioPath
    Path to TX15 SD card (default: D:\)

.PARAMETER GitPath
    Path to Git repository EdgeTX folder
    (default: C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX)

.PARAMETER WhatIf
    Show what would be done without making changes

.PARAMETER Confirm
    Prompt before making changes

.EXAMPLE
    .\Sync-TX15Config.ps1 -Mode SyncToRadio
    
    Copies new/modified files from Git to radio, no deletions

.EXAMPLE
    .\Sync-TX15Config.ps1 -Mode MirrorFromRadio -WhatIf
    
    Shows what would be copied/deleted without making changes

.NOTES
    Author: RC Configuration Assistant
    Version: 1.0.0
    WBS Reference: 03.00.00
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('SyncToRadio', 'SyncFromRadio', 'MirrorToRadio', 'MirrorFromRadio')]
    [string]$Mode,
    
    [Parameter(Mandatory=$false)]
    [string]$RadioPath = "D:\",
    
    [Parameter(Mandatory=$false)]
    [string]$GitPath = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX"
)

# WBS: 03.01.01 - Validate paths
function Test-03.01.01-ValidatePaths {
    [CmdletBinding()]
    param(
        [string]$Radio,
        [string]$Git
    )
    
    Write-Verbose "[03.01.01] Validating paths..."
    
    if (-not (Test-Path $Radio)) {
        throw "Radio path not found: $Radio. Ensure TX15 is connected."
    }
    
    if (-not (Test-Path $Git)) {
        throw "Git path not found: $Git. Verify repository location."
    }
    
    # Check for EdgeTX signature
    $radioFiles = Get-ChildItem -Path $Radio -Directory | Select-Object -ExpandProperty Name
    $expectedDirs = @('MODELS', 'SCRIPTS', 'SOUNDS')
    $found = $expectedDirs | Where-Object { $radioFiles -contains $_ }
    
    if ($found.Count -lt 2) {
        Write-Warning "Radio path may not be a valid EdgeTX SD card. Expected directories: $($expectedDirs -join ', ')"
    }
    
    Write-Verbose "[03.01.01] Path validation complete."
    return $true
}

# WBS: 03.01.02 - Get folder structure
function Get-03.01.02-FolderStructure {
    [CmdletBinding()]
    param(
        [string]$BasePath
    )
    
    Write-Verbose "[03.01.02] Getting folder structure from: $BasePath"
    
    # EdgeTX standard folders
    $folders = @(
        'MODELS',
        'SCRIPTS',
        'SCRIPTS\MIXES',
        'SCRIPTS\FUNCTIONS', 
        'SCRIPTS\TELEMETRY',
        'SCRIPTS\TOOLS',
        'THEMES',
        'SOUNDS',
        'SOUNDS\en',
        'SOUNDS\custom',
        'FIRMWARE',
        'LOGS',
        'SCREENSHOTS'
    )
    
    $result = @()
    foreach ($folder in $folders) {
        $fullPath = Join-Path $BasePath $folder
        if (Test-Path $fullPath) {
            $result += $folder
        }
    }
    
    Write-Verbose "[03.01.02] Found $($result.Count) folders."
    return $result
}

# WBS: 03.01.03 - Compare files
function Compare-03.01.03-Files {
    [CmdletBinding()]
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$RelativePath
    )
    
    $sourceFull = Join-Path $SourcePath $RelativePath
    $destFull = Join-Path $DestPath $RelativePath
    
    if (-not (Test-Path $sourceFull)) {
        return $null
    }
    
    $sourceItem = Get-Item $sourceFull
    
    # If destination doesn't exist, source is newer
    if (-not (Test-Path $destFull)) {
        return @{
            Action = 'Copy'
            Source = $sourceFull
            Dest = $destFull
            Reason = 'New file'
        }
    }
    
    $destItem = Get-Item $destFull
    
    # Compare modification times
    if ($sourceItem.LastWriteTime -gt $destItem.LastWriteTime) {
        return @{
            Action = 'Copy'
            Source = $sourceFull
            Dest = $destFull
            Reason = 'Source newer'
        }
    }
    
    # Files are in sync
    return $null
}

# WBS: 03.02.01 - Sync to radio (update only)
function Sync-03.02.01-ToRadio {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$GitPath,
        [string]$RadioPath
    )
    
    Write-Host "`n[03.02.01] Sync To Radio - Update new files only" -ForegroundColor Cyan
    Write-Host "Source: $GitPath" -ForegroundColor Gray
    Write-Host "Dest:   $RadioPath`n" -ForegroundColor Gray
    
    $folders = Get-03.01.02-FolderStructure -BasePath $GitPath
    $operations = @()
    
    foreach ($folder in $folders) {
        $sourceFolderPath = Join-Path $GitPath $folder
        $destFolderPath = Join-Path $RadioPath $folder
        
        # Ensure destination folder exists
        if (-not (Test-Path $destFolderPath)) {
            if ($PSCmdlet.ShouldProcess($destFolderPath, "Create directory")) {
                New-Item -ItemType Directory -Path $destFolderPath -Force | Out-Null
                Write-Host "[+] Created: $folder" -ForegroundColor Green
            }
        }
        
        # Get files in source folder
        $files = Get-ChildItem -Path $sourceFolderPath -File -Recurse
        
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($sourceFolderPath.Length + 1)
            $destFile = Join-Path $destFolderPath $relativePath
            
            $comparison = Compare-03.01.03-Files `
                -SourcePath $sourceFolderPath `
                -DestPath $destFolderPath `
                -RelativePath $relativePath
            
            if ($comparison) {
                $operations += $comparison
                
                if ($PSCmdlet.ShouldProcess($destFile, "Copy file")) {
                    # Ensure parent directory exists
                    $destDir = Split-Path $destFile -Parent
                    if (-not (Test-Path $destDir)) {
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                    }
                    
                    Copy-Item -Path $file.FullName -Destination $destFile -Force
                    Write-Host "[→] $folder\$relativePath" -ForegroundColor Yellow
                    Write-Host "    Reason: $($comparison.Reason)" -ForegroundColor Gray
                }
            }
        }
    }
    
    Write-Host "`n[03.02.01] Complete: $($operations.Count) files synced." -ForegroundColor Green
    return $operations
}

# WBS: 03.02.02 - Sync from radio (update only)
function Sync-03.02.02-FromRadio {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$RadioPath,
        [string]$GitPath
    )
    
    Write-Host "`n[03.02.02] Sync From Radio - Update new files only" -ForegroundColor Cyan
    Write-Host "Source: $RadioPath" -ForegroundColor Gray
    Write-Host "Dest:   $GitPath`n" -ForegroundColor Gray
    
    $folders = Get-03.01.02-FolderStructure -BasePath $RadioPath
    $operations = @()
    
    foreach ($folder in $folders) {
        # Skip certain folders when syncing from radio
        if ($folder -match '^(LOGS|SCREENSHOTS)') {
            Write-Verbose "Skipping: $folder (excluded from git sync)"
            continue
        }
        
        $sourceFolderPath = Join-Path $RadioPath $folder
        $destFolderPath = Join-Path $GitPath $folder
        
        # Ensure destination folder exists
        if (-not (Test-Path $destFolderPath)) {
            if ($PSCmdlet.ShouldProcess($destFolderPath, "Create directory")) {
                New-Item -ItemType Directory -Path $destFolderPath -Force | Out-Null
                Write-Host "[+] Created: $folder" -ForegroundColor Green
            }
        }
        
        # Get files in source folder
        $files = Get-ChildItem -Path $sourceFolderPath -File -Recurse
        
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($sourceFolderPath.Length + 1)
            $destFile = Join-Path $destFolderPath $relativePath
            
            $comparison = Compare-03.01.03-Files `
                -SourcePath $sourceFolderPath `
                -DestPath $destFolderPath `
                -RelativePath $relativePath
            
            if ($comparison) {
                $operations += $comparison
                
                if ($PSCmdlet.ShouldProcess($destFile, "Copy file")) {
                    # Ensure parent directory exists
                    $destDir = Split-Path $destFile -Parent
                    if (-not (Test-Path $destDir)) {
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                    }
                    
                    Copy-Item -Path $file.FullName -Destination $destFile -Force
                    Write-Host "[←] $folder\$relativePath" -ForegroundColor Yellow
                    Write-Host "    Reason: $($comparison.Reason)" -ForegroundColor Gray
                }
            }
        }
    }
    
    Write-Host "`n[03.02.02] Complete: $($operations.Count) files synced." -ForegroundColor Green
    return $operations
}

# WBS: 03.03.01 - Mirror to radio (sync + delete)
function Sync-03.03.01-MirrorToRadio {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [string]$GitPath,
        [string]$RadioPath
    )
    
    Write-Host "`n[03.03.01] Mirror To Radio - Full sync with deletions" -ForegroundColor Red
    Write-Warning "This will DELETE files on radio that don't exist in Git!"
    Write-Host "Source: $GitPath" -ForegroundColor Gray
    Write-Host "Dest:   $RadioPath`n" -ForegroundColor Gray
    
    if (-not $PSCmdlet.ShouldProcess($RadioPath, "Mirror from Git (with deletions)")) {
        return
    }
    
    # First do regular sync
    $operations = Sync-03.02.01-ToRadio -GitPath $GitPath -RadioPath $RadioPath
    
    # Then find and delete extra files
    $folders = Get-03.01.02-FolderStructure -BasePath $RadioPath
    $deletions = @()
    
    foreach ($folder in $folders) {
        $radioFolderPath = Join-Path $RadioPath $folder
        $gitFolderPath = Join-Path $GitPath $folder
        
        if (-not (Test-Path $gitFolderPath)) {
            # Entire folder doesn't exist in git - delete it
            if ($PSCmdlet.ShouldProcess($radioFolderPath, "Delete directory")) {
                Remove-Item -Path $radioFolderPath -Recurse -Force
                Write-Host "[-] Deleted folder: $folder" -ForegroundColor Red
                $deletions += $folder
            }
            continue
        }
        
        # Check files in folder
        $radioFiles = Get-ChildItem -Path $radioFolderPath -File -Recurse
        
        foreach ($file in $radioFiles) {
            $relativePath = $file.FullName.Substring($radioFolderPath.Length + 1)
            $gitFile = Join-Path $gitFolderPath $relativePath
            
            if (-not (Test-Path $gitFile)) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Delete file")) {
                    Remove-Item -Path $file.FullName -Force
                    Write-Host "[-] $folder\$relativePath" -ForegroundColor Red
                    $deletions += $file.FullName
                }
            }
        }
    }
    
    Write-Host "`n[03.03.01] Complete: $($operations.Count) files synced, $($deletions.Count) items deleted." -ForegroundColor Green
    return @{
        Copied = $operations
        Deleted = $deletions
    }
}

# WBS: 03.03.02 - Mirror from radio (sync + delete)
function Sync-03.03.02-MirrorFromRadio {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [string]$RadioPath,
        [string]$GitPath
    )
    
    Write-Host "`n[03.03.02] Mirror From Radio - Full sync with deletions" -ForegroundColor Red
    Write-Warning "This will DELETE files in Git that don't exist on radio!"
    Write-Host "Source: $RadioPath" -ForegroundColor Gray
    Write-Host "Dest:   $GitPath`n" -ForegroundColor Gray
    
    if (-not $PSCmdlet.ShouldProcess($GitPath, "Mirror from radio (with deletions)")) {
        return
    }
    
    # First do regular sync
    $operations = Sync-03.02.02-FromRadio -RadioPath $RadioPath -GitPath $GitPath
    
    # Then find and delete extra files
    $folders = Get-03.01.02-FolderStructure -BasePath $GitPath
    $deletions = @()
    
    foreach ($folder in $folders) {
        # Skip LOGS and SCREENSHOTS (not synced to git)
        if ($folder -match '^(LOGS|SCREENSHOTS)') {
            continue
        }
        
        $gitFolderPath = Join-Path $GitPath $folder
        $radioFolderPath = Join-Path $RadioPath $folder
        
        if (-not (Test-Path $radioFolderPath)) {
            # Entire folder doesn't exist on radio - delete it from git
            if ($PSCmdlet.ShouldProcess($gitFolderPath, "Delete directory")) {
                Remove-Item -Path $gitFolderPath -Recurse -Force
                Write-Host "[-] Deleted folder: $folder" -ForegroundColor Red
                $deletions += $folder
            }
            continue
        }
        
        # Check files in folder
        $gitFiles = Get-ChildItem -Path $gitFolderPath -File -Recurse
        
        foreach ($file in $gitFiles) {
            $relativePath = $file.FullName.Substring($gitFolderPath.Length + 1)
            $radioFile = Join-Path $radioFolderPath $relativePath
            
            if (-not (Test-Path $radioFile)) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Delete file")) {
                    Remove-Item -Path $file.FullName -Force
                    Write-Host "[-] $folder\$relativePath" -ForegroundColor Red
                    $deletions += $file.FullName
                }
            }
        }
    }
    
    Write-Host "`n[03.03.02] Complete: $($operations.Count) files synced, $($deletions.Count) items deleted." -ForegroundColor Green
    return @{
        Copied = $operations
        Deleted = $deletions
    }
}

# WBS: 03.04.01 - Git commit helper
function Invoke-03.04.01-GitCommit {
    [CmdletBinding()]
    param(
        [string]$GitPath,
        [string]$Message
    )
    
    Write-Host "`n[03.04.01] Creating Git commit..." -ForegroundColor Cyan
    
    Push-Location $GitPath
    
    try {
        # Check if there are changes
        $status = git status --porcelain
        
        if (-not $status) {
            Write-Host "No changes to commit." -ForegroundColor Yellow
            return
        }
        
        # Stage all changes
        git add -A
        Write-Host "Staged all changes" -ForegroundColor Gray
        
        # Commit
        git commit -m $Message
        Write-Host "Committed: $Message" -ForegroundColor Green
        
        # Show summary
        git log -1 --oneline
        
    }
    finally {
        Pop-Location
    }
}

# Main execution
# WBS: 03.00.00 - Main sync controller
function Invoke-SyncController {
    Write-Host "`n===================================" -ForegroundColor Cyan
    Write-Host "TX15 Configuration Sync Tool" -ForegroundColor Cyan
    Write-Host "WBS: 03.00.00" -ForegroundColor Gray
    Write-Host "===================================`n" -ForegroundColor Cyan
    
    # Validate paths
    Test-03.01.01-ValidatePaths -Radio $RadioPath -Git $GitPath
    
    # Execute requested sync mode
    $result = $null
    switch ($Mode) {
        'SyncToRadio' {
            $result = Sync-03.02.01-ToRadio -GitPath $GitPath -RadioPath $RadioPath
        }
        'SyncFromRadio' {
            $result = Sync-03.02.02-FromRadio -RadioPath $RadioPath -GitPath $GitPath
            
            # Offer to commit
            if ($result.Count -gt 0 -and -not $WhatIfPreference) {
                $commit = Read-Host "`nCommit changes to Git? (y/n)"
                if ($commit -eq 'y') {
                    $msg = Read-Host "Commit message"
                    if (-not $msg) {
                        $msg = "[03.02.02] Sync from radio - $($result.Count) files updated"
                    }
                    Invoke-03.04.01-GitCommit -GitPath $GitPath -Message $msg
                }
            }
        }
        'MirrorToRadio' {
            $result = Sync-03.03.01-MirrorToRadio -GitPath $GitPath -RadioPath $RadioPath
        }
        'MirrorFromRadio' {
            $result = Sync-03.03.02-MirrorFromRadio -RadioPath $RadioPath -GitPath $GitPath
            
            # Offer to commit
            if (($result.Copied.Count -gt 0 -or $result.Deleted.Count -gt 0) -and -not $WhatIfPreference) {
                $commit = Read-Host "`nCommit changes to Git? (y/n)"
                if ($commit -eq 'y') {
                    $msg = Read-Host "Commit message"
                    if (-not $msg) {
                        $msg = "[03.03.02] Mirror from radio - $($result.Copied.Count) copied, $($result.Deleted.Count) deleted"
                    }
                    Invoke-03.04.01-GitCommit -GitPath $GitPath -Message $msg
                }
            }
        }
    }
    
    Write-Host "`n===================================`n" -ForegroundColor Cyan
    
    return $result
}

# Run main controller
Invoke-SyncController
