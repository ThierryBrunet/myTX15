# RadioMaster TX15 & ExpressLRS Configuration Project

## Overview

This project provides comprehensive tools, utilities, and documentation for configuring:
- RadioMaster TX15 transmitter with EdgeTX
- ExpressLRS (ELRS) receivers (multiple variants)
- Aircraft models (quadcopters and fixed wings)
- Gyro stabilization systems (Reflex V3, ICM-20948, ICM-45686)

## Project Structure

```
rc-config/
├── .cursor/               # Cursor IDE rules and instructions
│   ├── rules.md          # Main cursor rules
│   ├── edgetx-guide.md   # EdgeTX specific guidance
│   └── elrs-guide.md     # ExpressLRS specific guidance
├── tools/                # PowerShell and Python utilities
│   ├── sync-config.ps1   # Configuration synchronization tool
│   └── model-builder.ps1 # Model configuration generator
├── docs/                 # Documentation
│   ├── hardware.md       # Hardware specifications
│   ├── setup-guide.md    # Setup procedures
│   └── troubleshooting.md
├── models/               # Model configurations
│   ├── quadcopters/
│   └── fixed-wings/
└── sync/                 # Sync configurations
```

## Quick Start

1. Review hardware specifications in `docs/hardware.md`
2. Follow setup guide in `docs/setup-guide.md`
3. Use sync tools in `tools/` to synchronize configurations
4. Create model configurations using templates in `models/`

## Work Breakdown Structure (WBS)

### 01.00.00 - System Setup
- 01.01.00 - EdgeTX Installation
- 01.02.00 - ExpressLRS Setup
- 01.03.00 - Receiver Configuration

### 02.00.00 - Model Configuration
- 02.01.00 - Quadcopter Models
- 02.02.00 - Fixed Wing Models
- 02.03.00 - Safety & Arming

### 03.00.00 - Synchronization
- 03.01.00 - TX15 to Git
- 03.02.00 - Git to TX15
- 03.03.00 - Mirror Operations

### 04.00.00 - Advanced Features
- 04.01.00 - Flight Modes
- 04.02.00 - Mode Switching (Mode2 to Mode4)
- 04.03.00 - Gyro Integration

## Hardware Inventory

### Transmitter
- RadioMaster TX15 with EdgeTX (latest stable)

### Receivers
1. AliExpress ELRS 2.4GHz PWM 7CH CRSF Receiver (Cyclone)
2. HPXGRC 2.4G ExpressLRS ELRS Receiver
3. DarwinFPV F415 AIO Flight Controller with ELRS

### Gyroscopes
1. Reflex V3 Flight Controller Gyro Stabilizer
2. ICM-20948 Module 9 Axis MEMS (fixed wings)
3. ICM-45686 Module 6 Axis (quads)

### Aircraft
#### Quadcopters
- Angel30 3" Carbon Fiber Frame Kit

#### Fixed Wings
- Flying Bear FX707S
- 50CM Big Foam Plane
- EDGE540 EPP F3P

## Configuration Paths

- **TX15 SD Card**: `D:\`
- **Git Repository**: `C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX`

## Safety Notes

⚠️ **CRITICAL SAFETY REQUIREMENTS**
- Always implement 2-step arming sequences
- Test throttle cutoff before flight
- Verify failsafe settings
- Check control surface directions before first flight
- Use beginner modes when learning new aircraft

## Version Control

All configurations are version controlled in Git for:
- Change tracking
- Backup and recovery
- Configuration sharing
- Rollback capability

## Support Resources

- EdgeTX Documentation: https://edgetx.org
- ExpressLRS Documentation: https://www.expresslrs.org
- RadioMaster Support: https://www.radiomasterrc.com
