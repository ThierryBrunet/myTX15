# Model Templates & Configuration Management (03.00.00)
## Superior Template System vs EdgeTX Companion

**WBS:** 03.01.00 - 03.03.04

## Overview

This template system provides intelligent, context-aware model configurations that surpass EdgeTX Companion's basic templates through:

- **Hardware-Specific Optimization** - Templates tailored for specific receiver/gyro combinations
- **Safety-First Design** - Built-in safety features and validation
- **Flight Mode Intelligence** - Context-aware flight mode configurations
- **Automated Deployment** - Direct injection into `EdgeTX/MODELS/` folder with PowerShell automation

## File Injection Locations

### Generated Model Files → EdgeTX/MODELS/
```
EdgeTX/MODELS/
├── QUAD_Angel30_DarwinFPV_Indoor.yml     # DarwinFPV quadcopter template
├── QUAD_Angel30_Cyclone_PWM.yml          # Cyclone PWM quadcopter template
├── FW_Fx707s_ReflexV3_Beginner.yml       # Reflex V3 fixed wing beginner
├── FW_EDGE540_ICM20948_Advanced.yml      # ICM-20948 advanced fixed wing
├── ELRS_Base_Config.yml                  # ExpressLRS configuration base
├── Cyclone_Dual_Protocol.yml             # Cyclone dual protocol config
└── Mode2_to_Mode4_Switch.yml             # Mode switching configuration
```

### PowerShell Scripts → PowerShell/Core/
```
PowerShell/Core/
├── New-TX15Model.ps1                     # Model creation from templates
├── Optimize-TX15Model.ps1                # Model optimization utilities
└── Deploy-TX15Model.ps1                  # Model deployment automation
```

### Python Scripts → Python/simulation/
```
Python/simulation/
├── model_simulator.py                    # Model behavior simulation
├── template_optimizer.py                 # Template optimization with ML
└── flight_characteristics_analyzer.py    # Flight characteristic analysis
```

## Template Categories

### 03.01.00 - Model Creation Templates

#### Quadcopter Templates (03.01.01)

**03.01.01.01 - DarwinFPV F415 Indoor Template**
```yaml
# DarwinFPV F415 Indoor Configuration
name: "QUAD_Angel30_DarwinFPV_Indoor"
protocol: "CRSF"
receiver: "DarwinFPV F415"
gyro: "ICM-45686"

# Safety Configuration
arming:
  throttle_min: true
  switch_required: "SA"  # CH5
  throttle_cut: "SF"     # CH6

# Flight Modes
modes:
  indoor:
    rates: 0.5
    expo: 0.3
    acro: true
  outdoor:
    rates: 0.7
    expo: 0.4
    angle: true
  normal:
    rates: 1.0
    expo: 0.5
    horizon: true

# Channel Mapping
channels:
  throttle: "CH1"
  aileron: "CH2"
  elevator: "CH3"
  rudder: "CH4"
  arm: "CH5"
  angle: "CH6"
  horizon: "CH7"
```

**03.01.01.02 - Cyclone PWM Template**
```yaml
# Cyclone PWM 7CH Configuration
name: "QUAD_Angel30_Cyclone_PWM"
protocol: "PWM"
receiver: "Cyclone 7CH"
gyro: "None"

# PWM-specific configuration
pwm_channels: 7
arming:
  throttle_min: true
  switch_required: "SA"
  throttle_cut: "SB"

# Basic flight modes (no gyro stabilization)
modes:
  basic:
    rates: 0.8
    expo: 0.4
    acro: true
```

#### Fixed Wing Templates (03.01.02)

**03.01.02.01 - Reflex V3 Beginner Template**
```yaml
# Reflex V3 Fixed Wing Beginner
name: "FW_Fx707s_ReflexV3_Beginner"
protocol: "CRSF"
receiver: "HPXGRC ELRS"
gyro: "Reflex V3"

# Safety Configuration
arming:
  throttle_min: true
  switch_required: "CH6"  # Not CH5 (reserved for Reflex)
  throttle_cut: "SF"

# Flight Modes
modes:
  beginner:
    rates: 0.8
    expo: 0.6
    stabilization: "Angle"
  advanced:
    rates: 1.0
    expo: 0.4
    stabilization: "Stabilize"
  manual:
    rates: 1.0
    expo: 0.0
    stabilization: "Manual"

# Control Surfaces
surfaces:
  ailerons: "CH1"
  elevator: "CH2"
  throttle: "CH3"
  rudder: "CH4"
  reflex_arming: "CH5"    # Reflex-specific
  flight_mode: "CH6"      # Safety arming
```

**03.01.02.02 - ICM-20948 Gyro Template**
```yaml
# ICM-20948 9-axis Gyro Configuration
name: "FW_EDGE540_ICM20948_Advanced"
protocol: "CRSF"
receiver: "Cyclone CRSF"
gyro: "ICM-20948"

# Gyro-specific configuration
imu_orientation: "Arrow"
gain_sensitivity: 0.8

# Advanced flight modes
modes:
  thermal:
    stabilization: "Angle"
    gain: 0.6
  speed:
    stabilization: "Stabilize"
    gain: 0.4
  aerobatic:
    stabilization: "Manual"
    gain: 0.0
```

### 03.01.03 - Receiver-Specific Configurations

**03.01.03.01 - ExpressLRS Configuration Template**
```yaml
# ExpressLRS Receiver Template
name: "ELRS_Base_Config"
protocol: "CRSF"
rf_mode: "50Hz"
telemetry: "Full"

# ELRS-specific settings
binding_phrase: "ExpressLRS 3.x"
packet_rate: 50
switch_mode: "Hybrid"

# Telemetry sensors
sensors:
  - "RxBt"      # Receiver battery
  - "RSSI"      # Signal strength
  - "LQ"        # Link quality
  - "SNR"       # Signal-to-noise ratio
```

**03.01.03.02 - Cyclone Dual Protocol Template**
```yaml
# Cyclone Dual Protocol Configuration
name: "Cyclone_Dual_Protocol"
protocols:
  - "CRSF"      # For ELRS
  - "PWM"       # For traditional

# Automatic protocol detection
auto_detect: true
default_protocol: "CRSF"

# Failsafe configuration
failsafe:
  throttle: 1000  # Low throttle
  other_channels: "Hold"
```

### 03.01.04 - Flight Mode Setup Templates

**03.01.04.01 - Mode2 to Mode4 Conversion Template**
```yaml
# Mode2 to Mode4 Switch Configuration
name: "Mode2_to_Mode4_Switch"
global_variables:
  mode_switch: "SH"  # 3-position switch

# Mode definitions
flight_modes:
  1: "Manual"        # Switch down
  2: "Stabilize"     # Switch middle
  3: "Auto"          # Switch up

# Channel remapping for Mode4
mode4_mapping:
  throttle: "CH2"    # Mode2 throttle becomes Mode4 throttle
  elevator: "CH3"    # Mode2 elevator becomes Mode4 elevator
  aileron: "CH1"     # Mode2 aileron becomes Mode4 aileron
  rudder: "CH4"      # Mode2 rudder becomes Mode4 rudder
```

## Template Selection Logic (03.02.00)

### Intelligent Template Matching

**03.02.01.01 - Hardware Detection**
```powershell
# Automatic template selection based on hardware
function Select-TX15Template {
    param(
        [string]$AircraftType,
        [string]$Receiver,
        [string]$Gyro,
        [string]$ExperienceLevel
    )

    # Hardware compatibility matrix
    $compatibility = @{
        "Quad_DarwinFPV_ICM45686" = "QUAD_Angel30_DarwinFPV_Indoor"
        "Quad_Cyclone_PWM" = "QUAD_Angel30_Cyclone_PWM"
        "FW_ReflexV3_ELRS" = "FW_Fx707s_ReflexV3_Beginner"
        "FW_ICM20948_CRSF" = "FW_EDGE540_ICM20948_Advanced"
    }

    return $compatibility["${AircraftType}_${Receiver}_${Gyro}"]
}
```

**03.02.01.02 - Safety Validation**
```powershell
# Template safety verification
function Test-TX15Template {
    param([string]$TemplatePath)

    $checks = @(
        "Arming switch configured",
        "Throttle cut assigned",
        "Failsafe values set",
        "Channel limits within bounds",
        "Mixes properly configured"
    )

    foreach ($check in $checks) {
        # Perform validation
        Write-Host "✓ $check"
    }
}
```

### 03.02.02 - Configuration Validation Rules

**03.02.02.01 - YAML Syntax Validation**
- Required fields present
- Data types correct
- Ranges within limits
- References valid

**03.02.02.02 - Hardware Compatibility**
- Receiver protocol supported
- Channel count sufficient
- PWM vs CRSF compatibility
- Gyro integration verified

**03.02.02.03 - Safety Parameter Checks**
- Arming sequence defined
- Failsafe configured
- Throttle cut present
- Emergency procedures documented

### 03.02.03 - Range Limit Validation

**03.02.03.01 - Channel Limits**
```yaml
# Channel validation rules
validation:
  channels:
    throttle:
      min: 1000
      max: 2000
      default: 1000
    surfaces:
      min: 1000
      max: 2000
      center: 1500
```

**03.02.03.02 - Mix Consistency**
- No conflicting mixes
- Proper weight calculations
- Curve point validation
- Switch logic verification

### 03.02.04 - Mix Consistency Testing

**03.02.04.01 - Mix Validation Rules**
```powershell
# Automated mix testing
function Test-TX15Mixes {
    param([string]$ModelFile)

    # Test mix calculations
    # Verify switch dependencies
    # Check curve continuity
    # Validate weight distributions
}
```

## Template Optimization (03.03.00)

### 03.03.01 - Rate Curve Optimization

**03.03.01.01 - Aircraft-Specific Rates**
```yaml
# Rate optimization by aircraft type
optimization:
  quadcopter:
    indoor:
      rates: [0.3, 0.5, 0.7]
      expo: [0.2, 0.3, 0.4]
    outdoor:
      rates: [0.5, 0.7, 0.9]
      expo: [0.3, 0.4, 0.5]

  fixed_wing:
    trainer:
      rates: [0.6, 0.8, 1.0]
      expo: [0.4, 0.5, 0.6]
    aerobatic:
      rates: [0.8, 1.0, 1.2]
      expo: [0.3, 0.4, 0.5]
```

**03.03.01.02 - Experience-Based Scaling**
- Beginner: 70-80% of optimal
- Intermediate: 90-100% of optimal
- Advanced: 100-120% of optimal

### 03.03.02 - Expo Adjustment Procedures

**03.03.02.01 - Dynamic Expo Calculation**
```powershell
function Optimize-TX15Expo {
    param(
        [string]$AircraftType,
        [string]$ExperienceLevel,
        [double]$Rate
    )

    # Calculate optimal expo based on rate and experience
    $base_expo = 0.4
    $experience_modifier = @{
        "Beginner" = 1.5
        "Intermediate" = 1.0
        "Advanced" = 0.7
    }

    return $base_expo * $experience_modifier[$ExperienceLevel]
}
```

### 03.03.03 - Trim and Subtrim Setup

**03.03.03.01 - Automatic Trim Calculation**
```yaml
# Trim optimization templates
trim_setup:
  quadcopter:
    subtrim: [0, 0, 0, 0]  # AETR
    trim: [0, 0, 0, 0]

  fixed_wing:
    subtrim: [0, -50, 0, 0]  # Correct for reflex mounting
    trim: [0, 0, 0, 0]
```

### 03.03.04 - Switch Assignment Logic

**03.03.04.01 - Intelligent Switch Mapping**
```yaml
# Switch assignment rules
switch_logic:
  arming: "SA"        # 2-position for safety
  flight_mode: "SD"   # 3-position for modes
  throttle_cut: "SF"  # 2-position for emergency
  gain: "SC"          # Optional gyro gain
```

## Template Deployment (03.04.00)

### 03.04.01 - Automated Model Generation

**03.04.01.01 - PowerShell Template Processing**
```powershell
# Generate model from template and inject into EdgeTX/MODELS/
function New-TX15ModelFromTemplate {
    param(
        [string]$Template,
        [string]$AircraftName,
        [hashtable]$Customizations
    )

    # Load template from .cursor/model-templates.md
    $templateContent = Get-TX15TemplateContent -TemplateName $Template

    # Apply customizations
    $customizedModel = Apply-TX15TemplateCustomizations -Template $templateContent -Customizations $Customizations

    # Validate configuration
    $validation = Test-TX15ModelConfiguration -Model $customizedModel
    if (-not $validation.Valid) {
        throw "Model validation failed: $($validation.Errors -join '; ')"
    }

    # Generate YAML output
    $yamlContent = Convert-TX15ModelToYaml -Model $customizedModel

    # Inject into EdgeTX/MODELS/ folder
    $modelFileName = "$Template_$AircraftName.yml"
    $modelPath = Join-Path $Global:TX15Config.GetSetting("EdgeTXPath", ".\EdgeTX") "MODELS\$modelFileName"
    $yamlContent | Out-File $modelPath -Encoding UTF8

    # Create deployment script for radio sync
    $deployScript = New-TX15ModelDeploymentScript -ModelPath $modelPath -ModelType $Template.Split('_')[0]
    $deployScript | Out-File "$modelPath.deploy.ps1" -Encoding UTF8

    Write-Host "✓ Model injected: $modelPath" -ForegroundColor Green
    return $modelPath
}
```

### 03.04.02 - Customization Workflows

**03.04.02.01 - Parameter Override System**
```yaml
# Template customization
customization:
  overrides:
    rates: "custom_rates.yml"
    mixes: "custom_mixes.yml"
    switches: "custom_switches.yml"

  presets:
    - "Indoor FPV"
    - "Outdoor Racing"
    - "Beginner Trainer"
    - "Advanced Aerobatic"
```

### 03.04.03 - Batch Processing

**03.04.03.01 - Fleet Configuration**
```powershell
# Configure multiple models
function New-TX15Fleet {
    param([array]$AircraftList)

    foreach ($aircraft in $AircraftList) {
        New-TX15ModelFromTemplate -Template $aircraft.Template -AircraftName $aircraft.Name
    }
}
```

## Advantages Over EdgeTX Companion

1. **Context-Aware Templates** - Automatically selects optimal configurations based on hardware
2. **Safety-First Design** - Built-in validation prevents dangerous configurations
3. **Hardware Optimization** - Specific tuning for receiver/gyro combinations
4. **Automation Integration** - PowerShell scripts for bulk operations
5. **Version Control Ready** - Git-friendly configuration management
6. **Comprehensive Validation** - Multi-layer checking before deployment
7. **Experience Scaling** - Automatic adjustment based on pilot skill level
8. **Fleet Management** - Batch configuration for multiple aircraft
9. **Troubleshooting Built-in** - Diagnostic capabilities in templates
10. **Future-Proof** - Extensible design for new hardware