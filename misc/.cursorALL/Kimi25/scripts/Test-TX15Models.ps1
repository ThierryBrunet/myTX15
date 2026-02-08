#Requires -Version 5.1
<#
.SYNOPSIS
    Validates EdgeTX model configuration files for syntax and safety compliance.

.DESCRIPTION
    Checks YAML syntax, validates safety configurations (arming, throttle cut),
    and verifies compliance with project standards.

.PARAMETER ModelsPath
    Path to MODELS folder

.EXAMPLE
    .\Test-TX15Models.ps1 -ModelsPath "D:\MODELS"
#>

param(
    [string]$ModelsPath = "D:\MODELS"
)

$ErrorActionPreference = "Continue"

function Test-YamlSyntax {
    param([string]$FilePath)

    $issues = @()
    $content = Get-Content $FilePath -Raw

    # Check for tabs
    if ($content -match "`t") {
        $issues += "Contains tabs (use 2 spaces)"
    }

    # Check for BOM
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $issues += "Contains UTF-8 BOM (save without BOM)"
    }

    # Basic YAML structure check
    $lines = $content -split "`n"
    $indentStack = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match "^\s*#" -or $line -match "^\s*$") { continue }

        $indent = $line.Length - $line.TrimStart().Length

        if ($indent % 2 -ne 0) {
            $issues += "Line $($i+1): Odd indentation (use multiples of 2)"
        }
    }

    return $issues
}

function Test-SafetyConfig {
    param([string]$FilePath)

    $issues = @()
    $content = Get-Content $FilePath -Raw

    # Check for arming configuration
    if ($content -notmatch "(arm|ARM|L01)") {
        $issues += "WARNING: No arming logic detected"
    }

    # Check for throttle cut
    if ($content -notmatch "(throttle.*cut|OverrideCH|CH3.*-100)") {
        $issues += "WARNING: No throttle cut configuration detected"
    }

    # Check for model name
    if ($content -notmatch "name:\s*\S+") {
        $issues += "ERROR: No model name defined"
    }

    return $issues
}

Write-Host "TX15 Model Validator" -ForegroundColor Cyan
Write-Host "Scanning: $ModelsPath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $ModelsPath)) {
    Write-Error "Models path not found: $ModelsPath"
    exit 1
}

$models = Get-ChildItem $ModelsPath -Filter "*.yml"
$totalIssues = 0

foreach ($model in $models) {
    Write-Host "Checking: $($model.Name)" -NoNewline

    $yamlIssues = Test-YamlSyntax $model.FullName
    $safetyIssues = Test-SafetyConfig $model.FullName
    $allIssues = $yamlIssues + $safetyIssues

    if ($allIssues.Count -eq 0) {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [$($allIssues.Count) issues]" -ForegroundColor Yellow
        $allIssues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        $totalIssues += $allIssues.Count
    }
}

Write-Host ""
Write-Host "Scan complete. Total issues: $totalIssues" -ForegroundColor $(if ($totalIssues -eq 0) { "Green" } else { "Yellow" })
