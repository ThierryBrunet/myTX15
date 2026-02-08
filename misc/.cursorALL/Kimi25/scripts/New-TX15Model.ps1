#Requires -Version 5.1
<#
.SYNOPSIS
    Creates a new TX15 model from standardized templates.

.DESCRIPTION
    Generates EdgeTX model YAML files with proper safety configurations,
    flight modes, and receiver-specific settings.

.PARAMETER ModelType
    Type of aircraft: Quad or FixedWing

.PARAMETER AircraftName
    Name of the aircraft (e.g., "Angel30", "Fx707s")

.PARAMETER Receiver
    Receiver type: Cyclone, HPXGRC, DarwinFPV, ReflexV3

.PARAMETER Config
    Flight configuration: Indoor, Outdoor, Normal (for quads) or Beginner, Advanced, Manual (for fixed wings)

.PARAMETER OutputPath
    Where to save the model file (default: D:\MODELS)

.EXAMPLE
    .\New-TX15Model.ps1 -ModelType Quad -AircraftName "Angel30" -Receiver DarwinFPV -Config Indoor

.EXAMPLE
    .\New-TX15Model.ps1 -ModelType FixedWing -AircraftName "Fx707s" -Receiver ReflexV3 -Config Beginner
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Quad", "FixedWing")]
    [string]$ModelType,

    [Parameter(Mandatory=$true)]
    [string]$AircraftName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Cyclone", "HPXGRC", "DarwinFPV", "ReflexV3")]
    [string]$Receiver,

    [Parameter(Mandatory=$true)]
    [string]$Config,

    [string]$OutputPath = "D:\MODELS",

    [switch]$AddModeSwitch
)

# 01.00.00 - Configuration Templates

$Templates = @{
    Quad = @{
        Base = @"
header:
  name: {MODEL_NAME}
  bitmap: {BITMAP}
  labels:
    - "{AIRCRAFT}"
    - "{CONFIG}"

timers:
  timer1:
    mode: THs
    switch: L01
    countdown: Voice
    value: 5:00

  timer2:
    mode: ON
    countdown: Beep
    value: 10:00

inputs:
  - name: Roll
    source: Ail
    weight: {RATE}%
    expo: 30%
    trim: true

  - name: Pitch
    source: Ele
    weight: {RATE}%
    expo: 30%
    trim: true

  - name: Throttle
    source: Thr
    weight: 100%
    trim: false

  - name: Yaw
    source: Rud
    weight: {YAW_RATE}%
    expo: 20%
    trim: true

  - name: Arm
    source: SA
    weight: 100%

  - name: Mode
    source: SB
    weight: 100%

mixes:
  CH1:
    source: Roll
    weight: {RATE}
    flightMode: {FLIGHT_MODE}

  CH2:
    source: Pitch
    weight: {RATE}
    flightMode: {FLIGHT_MODE}

  CH3:
    source: Throttle
    weight: {THROTTLE_LIMIT}
    curve: {THROTTLE_CURVE}

  CH4:
    source: Yaw
    weight: {YAW_RATE}

  CH5:
    - source: MAX
      weight: -100
      switch: '!L01'
      multiplex: REPLACE
    - source: MAX
      weight: 100
      switch: L01
      multiplex: REPLACE

  CH6:
    source: Mode
    weight: 100

logicalSwitches:
  L01:
    func: AND
    v1: SA↑
    v2: Thr<=-95%
    delay: 0.5s
    description: "Safe Arm - 2 step"

  L02:
    func: AND
    v1: L01
    v2: Thr>-95%
    description: "Motor Ready"

specialFunctions:
  SF01:
    switch: L01
    action: PlayTrack
    param: "armed"
    repeat: 1s

  SF02:
    switch: '!L01'
    action: PlayTrack
    param: "disarmed"

  SF03:
    switch: '!L01'
    action: OverrideCH
    param: CH3
    value: -100
    description: "Throttle Cut on Disarm"

flightModes:
  - name: "{CONFIG}"
    switch: {MODE_SWITCH}
    trim: Common

globalVariables:
  GV1:
    name: "StickMode"
    default: 0
    min: 0
    max: 1
    popup: true
"@

        Configs = @{
            Indoor = @{
                Rate = 50
                YawRate = 70
                ThrottleLimit = 100
                ThrottleCurve = "indoor_soft"
                FlightMode = "Indoor"
                ModeSwitch = "SB↑"
                Bitmap = "quad_indoor.bmp"
            }
            Outdoor = @{
                Rate = 70
                YawRate = 70
                ThrottleLimit = 85
                ThrottleCurve = "linear"
                FlightMode = "Outdoor"
                ModeSwitch = "SB-"
                Bitmap = "quad_outdoor.bmp"
            }
            Normal = @{
                Rate = 100
                YawRate = 100
                ThrottleLimit = 100
                ThrottleCurve = "linear"
                FlightMode = "Normal"
                ModeSwitch = "SB↓"
                Bitmap = "quad_normal.bmp"
            }
        }
    }

    FixedWing = @{
        Base = @"
header:
  name: {MODEL_NAME}
  bitmap: {BITMAP}
  labels:
    - "{AIRCRAFT}"
    - "{CONFIG}"

timers:
  timer1:
    mode: THs
    switch: L01
    countdown: Voice
    value: 8:00

  timer2:
    mode: ON
    countdown: Beep
    value: 15:00

inputs:
  - name: Aileron
    source: Ail
    weight: {RATE}%
    expo: 25%
    trim: true

  - name: Elevator
    source: Ele
    weight: {RATE}%
    expo: 30%
    trim: true

  - name: Throttle
    source: Thr
    weight: 100%
    trim: false

  - name: Rudder
    source: Rud
    weight: 100%
    expo: 25%
    trim: true

  - name: ReflexMode
    source: SC
    weight: 100%

  - name: Arm
    source: SD↑
    weight: 100%

mixes:
  CH1:
    source: Aileron
    weight: {RATE}
    flightMode: {FLIGHT_MODE}

  CH2:
    source: Elevator
    weight: {RATE}
    flightMode: {FLIGHT_MODE}

  CH3:
    source: Throttle
    weight: 100
    curve: "throttle_fw"

  CH4:
    source: Rudder
    weight: 100

  CH5:
    source: ReflexMode
    weight: 100

  CH6:
    - source: MAX
      weight: -100
      switch: '!L01'
      multiplex: REPLACE
    - source: MAX
      weight: 100
      switch: L01
      multiplex: REPLACE

logicalSwitches:
  L01:
    func: AND
    v1: SD↑
    v2: Thr<=-95%
    delay: 0.5s
    description: "Safe Arm - No CH5 use"

  L03:
    func: a<x
    v1: CH5
    v2: -33
    description: "Reflex Beginner Mode"

  L04:
    func: a<=x
    v1: CH5
    v2: 33
    and: '!L03'
    description: "Reflex Advanced Mode"

  L05:
    func: a>x
    v1: CH5
    v2: 33
    description: "Reflex Manual Mode"

specialFunctions:
  SF01:
    switch: L01
    action: PlayTrack
    param: "motor_armed"

  SF02:
    switch: '!L01'
    action: PlayTrack
    param: "motor_off"

  SF03:
    switch: L03
    action: PlayTrack
    param: "beginner_mode"

  SF04:
    switch: L04
    action: PlayTrack
    param: "advanced_mode"

  SF05:
    switch: L05
    action: PlayTrack
    param: "manual_mode"

  SF06:
    switch: '!L01'
    action: OverrideCH
    param: CH3
    value: -100
    description: "Throttle Cut on Disarm"

flightModes:
  - name: "{CONFIG}"
    switch: {MODE_SWITCH}
    trim: Common

globalVariables:
  GV1:
    name: "StickMode"
    default: 0
    min: 0
    max: 1
    popup: true
"@

        Configs = @{
            Beginner = @{
                Rate = 80
                FlightMode = "Beginner"
                ModeSwitch = "L03"
                Bitmap = "fw_beginner.bmp"
            }
            Advanced = @{
                Rate = 100
                FlightMode = "Advanced"
                ModeSwitch = "L04"
                Bitmap = "fw_advanced.bmp"
            }
            Manual = @{
                Rate = 100
                FlightMode = "Manual"
                ModeSwitch = "L05"
                Bitmap = "fw_manual.bmp"
            }
        }
    }
}

# 02.00.00 - Functions

function Add-Mode2Mode4Config {
    param([string]$YamlContent)

    $modeSwitchConfig = @"

# Mode2/Mode4 Switch Configuration (per youtube.com/watch?v=kiKQy736huM)
specialFunctions:
  SF_Mode2:
    switch: SH↑
    action: AdjustGV
    param: GV1
    value: 0
    enable: ON

  SF_Mode4:
    switch: SH↓
    action: AdjustGV
    param: GV1
    value: 1
    enable: ON

mixes:
  CH1_ModeSwitch:
    - source: Ail
      weight: 100
      switch: GV1=0
      multiplex: REPLACE
    - source: Rud
      weight: 100
      switch: GV1=1
      multiplex: REPLACE

  CH4_ModeSwitch:
    - source: Rud
      weight: 100
      switch: GV1=0
      multiplex: REPLACE
    - source: Ail
      weight: 100
      switch: GV1=1
      multiplex: REPLACE
"@

    return $YamlContent + $modeSwitchConfig
}

# 03.00.00 - Main Execution

Write-Host "TX15 Model Generator" -ForegroundColor Cyan
Write-Host "Type: $ModelType | Aircraft: $AircraftName | Receiver: $Receiver | Config: $Config" -ForegroundColor Gray
Write-Host ""

# Validate configuration exists
$configData = $Templates[$ModelType].Configs[$Config]
if (-not $configData) {
    Write-Error "Invalid configuration '$Config' for $ModelType"
    Write-Host "Valid configs for $ModelType`: $($Templates[$ModelType].Configs.Keys -join ', ')"
    exit 1
}

# Generate model name
$prefix = if ($ModelType -eq "Quad") { "QUAD" } else { "FW" }
$modelName = "${prefix}_${AircraftName}_${Receiver}_${Config}"

# Prepare template variables
$templateVars = @{
    MODEL_NAME = $modelName
    AIRCRAFT = $AircraftName
    RECEIVER = $Receiver
    CONFIG = $Config
    RATE = $configData.Rate
    YAW_RATE = $configData.YawRate
    THROTTLE_LIMIT = $configData.ThrottleLimit
    THROTTLE_CURVE = $configData.ThrottleCurve
    FLIGHT_MODE = $configData.FlightMode
    MODE_SWITCH = $configData.ModeSwitch
    BITMAP = $configData.Bitmap
}

# Replace template variables
$yamlContent = $Templates[$ModelType].Base
foreach ($key in $templateVars.Keys) {
    $yamlContent = $yamlContent.Replace("{$key}", $templateVars[$key])
}

# Add Mode2/Mode4 switch if requested
if ($AddModeSwitch) {
    $yamlContent = Add-Mode2Mode4Config $yamlContent
    Write-Host "Added Mode2/Mode4 switch configuration" -ForegroundColor Green
}

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Save file
$outputFile = Join-Path $OutputPath "$modelName.yml"
$yamlContent | Out-File $outputFile -Encoding UTF8NoBOM

Write-Host "Model created: $outputFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the generated YAML file" -ForegroundColor White
Write-Host "2. Run .\Test-TX15Models.ps1 to validate" -ForegroundColor White
Write-Host "3. Sync to radio: .\Sync-TX15Config.ps1 -Mode SyncToRadio" -ForegroundColor White
Write-Host "4. Test in EdgeTX Companion before flying" -ForegroundColor Yellow
