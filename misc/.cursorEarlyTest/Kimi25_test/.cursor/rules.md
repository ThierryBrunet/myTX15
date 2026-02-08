# Cursor Rules for RC Radio Configuration

## Project Context

This project manages RadioMaster TX15 transmitter configurations with EdgeTX firmware, ExpressLRS receivers, and various aircraft models (quadcopters and fixed wings).

## File Naming Conventions

### EdgeTX Models
- Model files: `[aircraft-name].yml` or `[aircraft-name].etx`
- Model images: `[aircraft-name].png` (320x180px)
- Location: `MODELS/` on SD card

### ExpressLRS Configuration
- Receiver config files: `[receiver-name].json`
- Hardware targets: Use official ELRS naming (e.g., `AliExpress_ELRS_2400_RX_PWM`)
- Location: `FIRMWARE/` on SD card

### Git Repository Structure
```
EdgeTX/
├── MODELS/           # Model configurations
├── SCRIPTS/          # Lua scripts
├── THEMES/           # UI themes
├── SOUNDS/           # Audio files
└── FIRMWARE/         # Firmware and receiver configs
```

## Code Standards

### PowerShell Scripts
- Use approved verbs (Get-, Set-, Sync-, New-, etc.)
- Include comment-based help
- Error handling with try/catch
- Use `-WhatIf` and `-Confirm` for destructive operations
- Follow WBS numbering in function names (e.g., `Sync-01.01.01-EdgeTXModels`)

### Python Scripts
- PEP 8 compliance
- Type hints for function signatures
- Docstrings for all functions
- Use pathlib for file operations
- WBS numbering in function names (e.g., `sync_01_01_01_edgetx_models()`)

## WBS Numbering Pattern

Format: `XX.YY.ZZ`
- XX = High-level phase (01-99)
- YY = Sub-step (01-99)
- ZZ = Detailed step (01-99)

Example hierarchy:
```
01.00.00 - EdgeTX Setup
  01.01.00 - Install Firmware
    01.01.01 - Download latest stable
    01.01.02 - Flash to TX15
    01.01.03 - Verify installation
  01.02.00 - Configure Radio Settings
    01.02.01 - Set owner name
    01.02.02 - Configure stick mode
```

## Safety Requirements

### Arming Sequences

#### Quadcopters (DarwinFPV F415 AIO)
```yaml
# 2-step arming pattern
step1: 
  - switch: SA (arm/disarm switch)
  - position: DOWN = disarmed, UP = armed
step2:
  - throttle: Must be at zero (< 5%)
  - condition: SA UP AND throttle < 5%
  - result: Motors armed

failsafe:
  - action: Immediate disarm on signal loss
  - throttle: Force to zero
```

#### Fixed Wings
```yaml
# 2-step arming (not using channel 5)
step1:
  - switch: SB (arm/disarm switch)
  - position: DOWN = disarmed, UP = armed
step2:
  - throttle: Must be at zero (< 5%)
  - condition: SB UP AND throttle < 5%
  - result: Motor armed

throttle_cutoff:
  - switch: SC (separate cutoff switch)
  - position: DOWN = throttle cut
  - channel: 6 or 7 (not 5)
```

## Flight Configuration Modes

### Quadcopters
1. **Indoor Mode**
   - Rates: 200°/s max
   - Expo: 50%
   - Throttle: Limited to 50%
   - Use: Beginner indoor flying

2. **Outdoor Mode**
   - Rates: 400°/s max
   - Expo: 30%
   - Throttle: Limited to 75%
   - Use: Beginner outdoor flying

3. **Normal Mode**
   - Rates: Full (per Betaflight config)
   - Expo: Per Betaflight config
   - Throttle: 100%
   - Use: Experienced pilots

### Fixed Wings (with Reflex V3)
1. **Beginner Mode**
   - Gyro: Full stabilization
   - Limits: 50% on all surfaces
   - Auto-level: Enabled

2. **Advanced Mode**
   - Gyro: Partial stabilization
   - Limits: 75% on all surfaces
   - Auto-level: Optional

3. **Full Manual Mode**
   - Gyro: Off or minimal
   - Limits: 100% on all surfaces
   - Auto-level: Disabled

## Mode2 to Mode4 Switching

Implement switch-based mode change (Mode2 ↔ Mode4) as per EdgeTX Quick Tip:
- Switch: SF (6-position recommended)
- Position 1-3: Mode2 (throttle left, aileron/elevator right)
- Position 4-6: Mode4 (throttle right, aileron/elevator left)
- Implementation: Use mixer override or input mapping

Reference: https://www.youtube.com/watch?v=kiKQy736huM

## Receiver-Specific Notes

### Cyclone (AliExpress ELRS 2.4GHz PWM 7CH)
- Config files: `7CH.json` (PWM mode) or `CRSF.json` (CRSF mode)
- Channels: 7 PWM outputs available
- Use case: Fixed wings with standard servos

### HPXGRC 2.4G ELRS
- Protocol: CRSF only
- Telemetry: Full support
- Use case: General purpose

### DarwinFPV F415 AIO
- Integrated: FC + 4in1 ESC + ELRS receiver
- Protocol: CRSF to Betaflight
- Use case: Quadcopters
- Arming: Via Betaflight configuration + TX switch

## AI Assistant Behavior

When working on RC configurations:

1. **Always verify safety**
   - Check arming sequences
   - Verify failsafe settings
   - Confirm throttle cutoff

2. **Use WBS numbering**
   - Apply to all functions and procedures
   - Maintain hierarchy

3. **Reference official docs**
   - EdgeTX: https://edgetx.org
   - ExpressLRS: https://www.expresslrs.org
   - Reflex V3: www.fmsmodel.com/page/reflex

4. **Preserve user configurations**
   - Never overwrite without confirmation
   - Use sync modes appropriately
   - Backup before major changes

5. **Prefer PowerShell**
   - Use PowerShell unless Python provides clear advantage
   - Leverage Windows integration
   - Use structured output (objects, not text)

## Sync Operations

### SyncToRadio
- Copy new/modified files from Git → SD card
- Skip existing files if not modified
- No deletions

### SyncFromRadio
- Copy new/modified files from SD card → Git
- Skip existing files if not modified
- No deletions

### MirrorToRadio
- Full sync from Git → SD card
- Delete files on SD card not in Git
- **Use with caution**

### MirrorFromRadio
- Full sync from SD card → Git
- Delete files in Git not on SD card
- **Use with caution**

## Testing Requirements

Before first flight of any model:
1. Verify receiver binding
2. Test all control surfaces (correct direction)
3. Test arming sequence (2-step verification)
4. Test throttle cutoff
5. Test failsafe behavior
6. Range test (at least 100m)
7. Test flight modes (beginner → advanced progression)

## Documentation Standards

- All .md files use proper markdown
- Include WBS references
- Link to external resources
- Provide examples
- Include safety warnings where applicable

## Version Control

- Commit after each successful sync
- Use meaningful commit messages
- Tag stable configurations
- Branch for experimental setups

Example commit message:
```
[01.02.03] Add Angel30 quad model - Indoor flight mode

- Created model configuration
- Implemented 2-step arming
- Added 3 flight modes (indoor/outdoor/normal)
- Configured DarwinFPV F415 receiver
```
