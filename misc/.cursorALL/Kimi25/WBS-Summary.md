# Work Breakdown Structure (WBS) Summary

## Project: RadioMaster TX15 EdgeTX Configuration Management

### 01.00.00 - Project Setup & Rules

#### 01.01.00 - Cursor IDE Integration
- **01.01.01**: Cursor Rules Definition (`00.01.01-cursor-rules.md`)
  - Hardware inventory and specifications
  - Software version requirements
  - Safety requirements and checklists
  - Configuration standards

- **01.01.02**: Model Templates (`00.01.02-model-templates.md`)
  - Quadcopter template (DarwinFPV F415)
  - Fixed wing template (Reflex V3)
  - Mode2/Mode4 switch template
  - Receiver-specific configurations

- **01.01.03**: Synchronization Skills (`00.01.03-sync-skills.md`)
  - Four sync modes (SyncToRadio, SyncFromRadio, MirrorToRadio, MirrorFromRadio)
  - Pre/post sync procedures
  - Conflict resolution strategies
  - Automation workflows

### 02.00.00 - Tools & Utilities

#### 02.01.00 - PowerShell Scripts
- **02.01.01**: Main Synchronization Script (`Sync-TX15Config.ps1`)
  - Environment validation
  - Backup creation
  - File synchronization with hash comparison
  - Post-sync validation
  - Git integration

- **02.01.02**: Model Validation (`Test-TX15Models.ps1`)
  - YAML syntax checking
  - Safety configuration verification
  - Tab/space validation
  - BOM detection

- **02.01.03**: Model Generator (`New-TX15Model.ps1`)
  - Template-based model creation
  - Quad/FixedWing support
  - Indoor/Outdoor/Normal modes (quads)
  - Beginner/Advanced/Manual modes (fixed wings)
  - Mode2/Mode4 switch option

- **02.01.04**: Receiver Configuration (`Set-ELRSReceiver.ps1`)
  - Cyclone configuration (CRSF/PWM)
  - HPXGRC configuration
  - DarwinFPV Betaflight setup
  - Flashing instructions

#### 02.02.00 - User Interface
- **02.02.01**: Batch Menu (`TX15-Manager.bat`)
  - Interactive menu system
  - PowerShell execution wrapper
  - Safety confirmations for destructive operations

### 03.00.00 - Documentation

#### 03.01.00 - Aircraft Setup Guides (`02.01.01-aircraft-setup.md`)
- **03.01.01**: Quadcopter Setup (Angel30)
  - DarwinFPV F415 configuration
  - Betaflight CLI commands
  - ELRS integration
  - 2-step arming implementation
  - Three flight configurations

- **03.01.02**: Fixed Wing Setup (Fx707s)
  - Reflex V3 configuration
  - Firmware update procedures
  - Wiring diagrams
  - Flight mode mapping
  - 2-step arming (CH6, not CH5)

- **03.01.03**: Mode2/Mode4 Switch Setup
  - Global variable configuration
  - Mix modifications
  - Verification procedures
  - Video reference

- **03.01.04**: Troubleshooting
  - Common issues and solutions
  - Emergency procedures
  - Safety protocols

### 04.00.00 - Configuration Management

#### 04.01.00 - Folder Structure
```
RadioMaster_TX15/
├── myTX15/
│   ├── EdgeTX/              # Synced with D:\ SD card
│   │   ├── MODELS/
│   │   ├── RADIO/
│   │   ├── SCRIPTS/
│   │   └── SOUNDS/
│   └── Backups/             # Versioned backups
├── Receivers/
│   ├── Cyclone/
│   ├── HPXGRC/
│   └── DarwinFPV/
└── Tools/
    └── PowerShell/
```

#### 04.02.00 - Naming Conventions
- **Models**: `[TYPE]_[AIRCRAFT]_[RECEIVER]_[CONFIG]`
  - Example: `QUAD_Angel30_DarwinFPV_Indoor`
  - Example: `FW_Fx707s_ReflexV3_Beginner`

#### 04.03.00 - Version Control
- Git integration for configuration tracking
- Timestamped backups before sync operations
- Commit message standards
- Branching strategy (main, develop, feature/*)

### 05.00.00 - Safety & Compliance

#### 05.01.00 - Arming Safety
- **Quadcopters**: 2-step arming (throttle min + switch) on CH5
- **Fixed Wings**: 2-step arming on CH6 (CH5 reserved for Reflex)
- Throttle cut on disarm for all models

#### 05.02.00 - Flight Configurations
- **Quads**: Indoor (50% rates), Outdoor (70% rates), Normal (100%)
- **Fixed Wings**: Beginner (80% throws), Advanced (100%), Manual (100%)

#### 05.03.00 - Pre-Flight Checklists
- Hardware inspection
- Control verification
- Range checks
- Failsafe testing

### 06.00.00 - Hardware Specifications

#### 06.01.00 - Transmitter
- RadioMaster TX15
- EdgeTX v2.11.4 (STM32F4)

#### 06.02.00 - Receivers
- Cyclone 2.4GHz PWM 7CH (7CH.json/CRSF.json)
- HPXGRC 2.4GHz ELRS
- DarwinFPV F415 AIO (Integrated)

#### 06.03.00 - Gyros/Stabilizers
- Reflex V3 (Fixed wings)
- ICM-20948 (9-axis, fixed wings)
- ICM-45686 (6-axis, quads)

#### 06.04.00 - Aircraft
- **Quads**: Angel30 3-inch
- **Fixed Wings**: Fx707s, 50CM Foam, EDGE540 EPP

### 07.00.00 - Software Versions

| Software | Version | Notes |
|----------|---------|-------|
| EdgeTX | v2.11.4 | Latest stable for TX15 |
| ExpressLRS | v3.5.4 | Latest stable |
| ELRS Configurator | Latest | Receiver flashing |
| EdgeTX Companion | v2.11.4 | Match firmware |
| PowerShell Scripts | 1.0.0 | This package |

## File Inventory

### Cursor Rules (`.cursor/`)
1. `00.01.01-cursor-rules.md` - Main project rules
2. `00.01.02-model-templates.md` - YAML templates
3. `00.01.03-sync-skills.md` - Synchronization guide

### Scripts (`scripts/`)
1. `Sync-TX15Config.ps1` - Main sync utility
2. `New-TX15Model.ps1` - Model generator
3. `Test-TX15Models.ps1` - Validation tool
4. `Set-ELRSReceiver.ps1` - Receiver config

### Documentation (`docs/`)
1. `02.01.01-aircraft-setup.md` - Setup guides

### Root Files
1. `README.md` - Project overview
2. `TX15-Manager.bat` - Interactive menu
3. `.cursorignore` - Cursor ignore patterns

## Usage Workflow

### Initial Setup
1. Extract zip to `C:\Users\thier\OneDrive\Workspaces\ExpressLRS\`
2. Copy `.cursor/` to your Cursor workspace
3. Run `TX15-Manager.bat` or use PowerShell scripts directly

### Daily Workflow
1. **Before flying**: `Sync-TX15Config.ps1 -Mode SyncFromRadio`
2. **Create new model**: `New-TX15Model.ps1` with appropriate parameters
3. **Validate**: `Test-TX15Models.ps1`
4. **Deploy**: `Sync-TX15Config.ps1 -Mode SyncToRadio`
5. **Test in Companion**: Verify before flying

### Safety Protocol
1. Always validate models before sync
2. Create backups before destructive operations
3. Test arming logic on bench
4. Verify throttle cut operation
5. Range check after major changes
