# RC Transmitter Configuration Rules

## Transmitter Configuration Standards

### Hardware Specifications
- **Transmitter**: RadioMaster TX15
- **Firmware**: EdgeTX (Latest non-RC version for TX15)
- **Protocol**: ExpressLRS (Latest non-RC version)
- **Companion Software**: ExpressLRS Companion (Latest non-RC version)

### Receiver Hardware Standards
1. **Cyclone (ELRS 2.4Ghz PWM 7CH CRSF)**: Use 7CH.json for PWM or CRSF.json for CRSF configuration
2. **HPXGRC 2.4G ExpressLRS ELRS Receiver**: Standard ELRS configuration
3. **DarwinFPV F415 AIO Flight Controller**: Integrated ELRS with 4-in-1 ESC capabilities

### Gyroscope Standards
- **Reflex V3 Flight Controller Gyro Stabilizer**: Primary for fixed-wing aircraft
- **ICM-20948 Module**: Preferred for fixed-wing applications (9-axis MEMS)
- **ICM-45686 Module**: Preferred for vibration-heavy quadcopters (6-axis)

## Aircraft Model Configuration Rules

### Arming Pattern Requirements

#### Quadcopter Arming (DarwinFPV F415 Compatible)
- **Two-step arming sequence**:
  1. **Pre-arm**: Throttle at minimum + specific switch combination
  2. **Arm**: Additional confirmation step
- **Throttle cutoff**: Automatic when disarmed
- **Safety interlocks**: Prevent accidental arming during setup

#### Fixed-Wing Arming (Non-channel 5 dependent)
- **Two-step arming sequence**:
  1. **Pre-arm**: Throttle at minimum + dedicated switch
  2. **Arm**: Separate confirmation switch
- **Throttle cutoff**: Independent of channel 5 usage
- **Safety features**: Arming disabled when throttle not at idle

### Flight Configuration Standards

#### Quadcopter Flight Modes
Each quadcopter model must include three flight configurations:

1. **Indoors Mode**:
   - Reduced control authority (50-70% of normal)
   - Limited throttle response
   - Beginner-friendly settings
   - Gentle flight characteristics

2. **Outdoors Mode**:
   - Moderate control authority (70-85% of normal)
   - Balanced throttle response
   - Intermediate settings
   - Suitable for outdoor learning

3. **Normal Mode**:
   - Full control authority (100% passthrough)
   - Direct Betaflight configuration mapping
   - Expert settings
   - Unrestricted flight capabilities

#### Fixed-Wing Flight Modes (Reflex V3 Compatible)
Each fixed-wing model must include three flight configurations:

1. **Beginner Mode**:
   - Maximum gyro assistance
   - Limited control surfaces
   - Stability augmentation
   - Crash-resistant settings

2. **Advanced Mode**:
   - Moderate gyro assistance
   - Full control surface authority
   - Balanced stability
   - Sport flying capabilities

3. **Full Manual Mode**:
   - Minimal gyro intervention
   - Direct control surface response
   - Manual flying experience
   - Competition settings

## Transmitter Control Standards

### Mode Switching
- **Mode 2 to Mode 4 conversion**: Implement via switch as per EdgeTX best practices
- **Switch assignment**: Dedicated toggle for mode switching
- **Safety verification**: Test mode switching before flight

### Channel Mapping Standards
- **Standard channels**: 1-4 (Aileron, Elevator, Throttle, Rudder)
- **Auxiliary channels**: 5+ for flight modes, arming, etc.
- **Consistent mapping**: Maintain across all aircraft types

## Synchronization Rules

### Digital Twin Management
- **Source**: Git repository EdgeTX folder (digital twin)
- **Target**: RadioMaster TX15 SD card ("d:\" drive)
- **Synchronization modes**:
  - SyncToRadio: Update new files, preserve existing
  - SyncFromRadio: Update new files, preserve existing
  - MirrorToRadio: Exact copy, remove extras
  - MirrorFromRadio: Exact copy, remove extras

### File Organization Rules
- **YAML configurations**: Store in appropriate EdgeTX subfolders
- **Lua scripts**: Store in EdgeTX SCRIPTS folder
- **Model files**: Organize by aircraft type and name
- **Backup strategy**: Maintain version history in git

## Development Workflow Rules

### Tool Usage Standards
- **PowerShell preference**: Use for file operations, synchronization
- **Python alternative**: Use when PowerShell limitations encountered
- **WBS numbering**: Apply xx.xx.xx format for all documentation

### Quality Assurance
- **Testing requirement**: Verify all configurations before flight
- **Documentation**: Maintain comprehensive setup instructions
- **Version control**: Track all configuration changes in git

### Safety Protocols
- **Pre-flight checks**: Mandatory verification of all settings
- **Failsafe testing**: Confirm failsafe behavior
- **Range testing**: Verify signal integrity before flight
- **Backup configurations**: Maintain known-good configurations