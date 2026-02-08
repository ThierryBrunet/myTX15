# RadioMaster TX15 EdgeTX Configuration

## Overview

This repository contains configuration files, documentation, and PowerShell utilities for managing RadioMaster TX15 transmitter settings with EdgeTX firmware, supporting multiple aircraft types with ExpressLRS receivers.

## Quick Start

### 1. Synchronize Configurations

**Backup from radio to Git:**
```powershell
.\scripts\Sync-TX15Config.ps1 -Mode SyncFromRadio -Verbose
```

**Deploy from Git to radio:**
```powershell
.\scripts\Sync-TX15Config.ps1 -Mode SyncToRadio -Verbose
```

### 2. Create New Model

**Quadcopter (Indoor mode):**
```powershell
.\scripts\New-TX15Model.ps1 -ModelType Quad -AircraftName "Angel30" -Receiver DarwinFPV -Config Indoor
```

**Fixed Wing (Beginner mode):**
```powershell
.\scripts\New-TX15Model.ps1 -ModelType FixedWing -AircraftName "Fx707s" -Receiver ReflexV3 -Config Beginner
```

### 3. Validate Models

```powershell
.\scripts\Test-TX15Models.ps1 -ModelsPath "D:\MODELS"
```

## Repository Structure

```
cursor_rc_config/
├── .cursor/                    # Cursor IDE rules and instructions
│   ├── 00.01.01-cursor-rules.md
│   ├── 00.01.02-model-templates.md
│   └── 00.01.03-sync-skills.md
├── scripts/                    # PowerShell utilities
│   ├── Sync-TX15Config.ps1    # Main sync tool
│   ├── New-TX15Model.ps1      # Model generator
│   ├── Test-TX15Models.ps1    # Validation tool
│   └── Set-ELRSReceiver.ps1   # Receiver config helper
├── docs/                       # Documentation
│   └── 02.01.01-aircraft-setup.md
└── README.md                   # This file
```

## Hardware Supported

### Transmitters
- RadioMaster TX15 (EdgeTX v2.11.4)

### Receivers
- Cyclone 2.4GHz PWM 7CH (CRSF/PWM modes)
- HPXGRC 2.4GHz ELRS
- DarwinFPV F415 AIO (Integrated ELRS)

### Flight Controllers/Stabilizers
- Reflex V3 (Fixed wings)
- Betaflight (Quadcopters)

### Aircraft
- **Quadcopters**: Angel30 3-inch
- **Fixed Wings**: Flying Bear Fx707s, 50CM Foam Plane, EDGE540 EPP

## Safety Features

All configurations include:
- **2-step arming** (throttle minimum + switch)
- **Throttle cut** on disarm
- **Flight mode restrictions** (Indoor/Outdoor/Beginner/Advanced)
- **Mode2/Mode4 switch** support

## Documentation

- [Cursor Rules](.cursor/00.01.01-cursor-rules.md) - Project standards and safety requirements
- [Model Templates](.cursor/00.01.02-model-templates.md) - YAML configuration templates
- [Sync Skills](.cursor/00.01.03-sync-skills.md) - Synchronization workflows
- [Aircraft Setup](docs/02.01.01-aircraft-setup.md) - Detailed setup guides

## Version Information

| Component | Version |
|-----------|---------|
| EdgeTX | v2.11.4 |
| ExpressLRS | v3.5.4 |
| PowerShell Scripts | 1.0.0 |

## Safety Warning

**Always**:
- Remove props when configuring quadcopters
- Test in EdgeTX Companion before flying
- Perform range checks
- Verify failsafe operation

**Never**:
- Fly without throttle cut configured
- Ignore arming safety checks
- Mix up models between aircraft

## License

These configuration files and scripts are provided as-is for educational and personal use. Always verify safety-critical configurations before flight.

## References

- [EdgeTX Documentation](https://manual.edgetx.org)
- [ExpressLRS Documentation](https://www.expresslrs.org)
- [RadioMaster TX15 Downloads](https://radiomasterrc.com/pages/tx15-downloads)
- [Mode2/Mode4 Switch Video](https://www.youtube.com/watch?v=kiKQy736huM)
