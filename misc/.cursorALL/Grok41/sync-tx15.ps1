<#
.SYNOPSIS
    Synchronize EdgeTX configuration between RadioMaster TX15 SD card and local git repository.
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("SyncToRadio","SyncFromRadio","MirrorToRadio","MirrorFromRadio")]
    [string]$Mode
)

$Radio = "D:\"
$Repo  = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX"

switch ($Mode) {
    "SyncToRadio"     { robocopy $Repo $Radio /E /XO /XD ".git" }
    "SyncFromRadio"   { robocopy $Radio $Repo /E /XO /XD ".git" }
    "MirrorToRadio"   { robocopy $Repo $Radio /MIR /XD ".git" }
    "MirrorFromRadio" { robocopy $Radio $Repo /MIR /XD ".git" }
}

Write-Host "$Mode completed."

