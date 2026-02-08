# Directory Structure and File Organization Guide

## 01. Repository Root Structure

### 01.01 Core Directories
```
myTX15/                          # Repository root
├── .cursor/                     # AI assistant configuration
│   ├── rules.md                 # Configuration rules
│   ├── instructions.md          # Setup instructions
│   ├── edgetx-overview.md       # EdgeTX documentation
│   ├── aircraft-templates.md    # Model templates
│   └── directory.md             # This file
├── EdgeTX/                      # Digital twin root
│   ├── MODELS/                  # Aircraft configurations
│   ├── SCRIPTS/                 # Lua scripts
│   ├── LOGS/                    # Flight data
│   └── RADIO/                   # Transmitter settings
├── PowerShell/                  # Synchronization scripts
│   ├── Core/                    # Shared functions
│   ├── Sync-TX15ToUsb.ps1       # Sync to radio
│   ├── Sync-UsbToTX15.ps1       # Sync from radio
│   ├── Sync-TX15ToUsb-Mirror.ps1 # Mirror to radio
│   └── Sync-UsbToTX15-Mirror.ps1 # Mirror from radio
├── Python/                      # Python utilities (if needed)
└── misc/                        # Additional resources
```

### 01.02 Hidden and Configuration Files
```
myTX15/
├── .gitignore                   # Git ignore patterns
├── .gitattributes              # Git attributes
├── README.md                   # Project documentation
└── LICENSE                     # License information
```

## 02. EdgeTX Digital Twin Structure

### 02.01 MODELS Directory
```
EdgeTX/MODELS/
├── quadcopters/                # Quadcopter models
│   ├── angel30-indoor.yml      # Angel30 indoor configuration
│   ├── angel30-outdoor.yml     # Angel30 outdoor configuration
│   ├── angel30-normal.yml      # Angel30 normal configuration
│   └── templates/
│       └── quadcopter-base.yml # Base quadcopter template
├── fixedwing/                  # Fixed-wing models
│   ├── fx707s-beginner.yml     # Fx707s beginner mode
│   ├── fx707s-advanced.yml     # Fx707s advanced mode
│   ├── fx707s-manual.yml       # Fx707s manual mode
│   ├── bigfoam-beginner.yml    # 50cm foam beginner
│   ├── bigfoam-advanced.yml    # 50cm foam advanced
│   ├── bigfoam-manual.yml      # 50cm foam manual
│   ├── edge540-beginner.yml    # EDGE540 beginner
│   ├── edge540-advanced.yml    # EDGE540 advanced
│   ├── edge540-manual.yml      # EDGE540 manual
│   └── templates/
│       └── fixedwing-base.yml  # Base fixed-wing template
└── shared/                     # Common configurations
    ├── arming-switches.yml     # Arming switch definitions
    ├── flight-modes.yml        # Flight mode templates
    └── safety-configs.yml      # Safety configurations
```

### 02.02 SCRIPTS Directory
```
EdgeTX/SCRIPTS/
├── FUNCTIONS/                  # Custom functions
│   ├── mode2to4.lua            # Mode switching logic
│   ├── arming-check.lua        # Arming verification
│   └── telemetry-display.lua   # Custom telemetry
├── MIXES/                      # Advanced mixing
│   ├── gyro-mixing.lua         # Gyro integration
│   ├── curve-adjust.lua        # Dynamic curves
│   └── expo-adjust.lua         # Expo modification
├── TELEMETRY/                  # Telemetry processing
│   ├── battery-monitor.lua     # Battery monitoring
│   ├── signal-quality.lua      # Signal strength
│   └── flight-logger.lua       # Data logging
└── WIDGETS/                    # Screen widgets
    ├── flight-timer.lua        # Flight time display
    ├── mode-indicator.lua      # Flight mode indicator
    └── battery-widget.lua      # Battery status
```

### 02.03 LOGS Directory
```
EdgeTX/LOGS/
├── flights/                    # Flight data logs
│   ├── 2024-01-15/            # Date-based organization
│   │   ├── angel30-flight-001.csv
│   │   ├── fx707s-flight-001.csv
│   │   └── ...
│   └── 2024-01-16/
├── telemetry/                  # Telemetry dumps
└── system/                     # System diagnostics
    ├── edgetx-logs/           # EdgeTX system logs
    └── sync-logs/             # Synchronization logs
```

### 02.04 RADIO Directory
```
EdgeTX/RADIO/
├── models.yml                  # Master model list
├── radio.yml                   # Transmitter configuration
├── hardware.ini               # Hardware settings
└── backups/                   # Configuration backups
    ├── pre-flight-test.yml    # Pre-test backup
    └── known-good.yml         # Last known working config
```

## 03. PowerShell Scripts Organization

### 03.01 Core Module Structure
```
PowerShell/Core/
├── Common.psm1                 # Shared functions
├── Logging.psm1               # Logging utilities
├── FileOps.psm1               # File operations
├── Validation.psm1            # Configuration validation
└── EdgeTX.psm1                # EdgeTX-specific functions
```

### 03.02 Synchronization Scripts
```
PowerShell/
├── Sync-TX15ToUsb.ps1         # Update radio with new files
├── Sync-UsbToTX15.ps1         # Update repo with radio changes
├── Sync-TX15ToUsb-Mirror.ps1  # Exact copy to radio
├── Sync-UsbToTX15-Mirror.ps1  # Exact copy from radio
└── Test-Sync.ps1              # Synchronization testing
```

## 04. Configuration File Naming Conventions

### 04.01 Model Files
**Format**: `{AircraftName}-{FlightMode}.yml`

**Examples**:
- `Angel30-Indoor.yml`
- `Fx707s-Beginner.yml`
- `EDGE540-Manual.yml`
- `BigFoam-Advanced.yml`

### 04.02 Script Files
**Format**: `{Function}-{Purpose}.lua`

**Examples**:
- `Mode2To4-Switch.lua`
- `Arming-SafetyCheck.lua`
- `Telemetry-BatteryMonitor.lua`
- `Curve-DynamicAdjust.lua`

### 04.03 Log Files
**Format**: `{Aircraft}-{Date}-{Sequence}.{extension}`

**Examples**:
- `Angel30-20240115-001.csv`
- `Fx707s-20240115-001.log`
- `System-20240115-001.txt`

## 05. Version Control Organization

### 05.01 Branch Structure
```
main                            # Production configurations
├── feature/                    # New aircraft additions
│   ├── angel30-setup
│   ├── fx707s-config
│   └── edge540-integration
├── hotfix/                     # Urgent fixes
│   ├── arming-safety
│   └── sync-bugfix
└── experimental/               # Testing new features
    ├── lua-scripts
    └── advanced-mixing
```

### 05.02 Commit Message Standards
**Format**: `{type}: {component} - {description}`

**Types**:
- `feat`: New features (models, scripts)
- `fix`: Bug fixes
- `docs`: Documentation updates
- `refactor`: Code restructuring
- `test`: Testing additions
- `chore`: Maintenance tasks

**Examples**:
- `feat: Angel30 - Add indoor flight configuration`
- `fix: Arming - Correct throttle cutoff logic`
- `docs: Instructions - Update setup procedures`
- `refactor: Scripts - Reorganize Lua functions`

## 06. File Relationship Mapping

### 06.01 Model Dependencies
```
Angel30-Indoor.yml
├── references: Angel30-Base.yml
├── uses: Arming-Switches.yml
└── requires: Gyro-Config-ICM45686.yml

Fx707s-Beginner.yml
├── references: FixedWing-Base.yml
├── uses: ReflexV3-Config.yml
└── requires: Mode2To4-Switch.lua
```

### 06.02 Script Dependencies
```
Mode2To4-Switch.lua
├── uses: Common-Functions.lua
└── modifies: Flight-Mode-Switching.yml

Telemetry-BatteryMonitor.lua
├── reads: CRSF-Telemetry-Data.yml
└── writes: Battery-Log-{date}.csv
```

## 07. Backup and Recovery Structure

### 07.01 Automated Backups
```
backups/
├── daily/                      # Daily snapshots
│   ├── 2024-01-15-full/
│   └── 2024-01-16-full/
├── pre-change/                 # Before modifications
│   ├── angel30-config-backup/
│   └── fx707s-script-backup/
└── known-good/                 # Verified working configs
    ├── v1.0-stable/
    └── v1.1-tested/
```

### 07.02 Recovery Procedures
1. **Identify backup source**: Daily, pre-change, or known-good
2. **Restore file structure**: Maintain directory hierarchy
3. **Validate configuration**: Run syntax and logic checks
4. **Test functionality**: Verify in safe environment
5. **Document recovery**: Record incident and resolution

## 08. Cross-Platform Compatibility

### 08.01 Path Handling
- **Windows paths**: Use forward slashes in scripts
- **Drive letters**: Abstract to variables (e.g., `$RadioDrive = "d:"`)
- **UNC paths**: Support network locations
- **Relative paths**: Prefer for repository operations

### 08.02 File Encoding
- **YAML files**: UTF-8 with BOM for EdgeTX compatibility
- **PowerShell scripts**: UTF-8 without BOM
- **Log files**: UTF-8 for international character support
- **Lua scripts**: ASCII for maximum compatibility

## 09. Maintenance Procedures

### 09.01 Regular Cleanup
- **Remove old logs**: Archive logs older than 90 days
- **Delete temporary files**: Clean sync artifacts
- **Compress backups**: Zip old backup directories
- **Update dependencies**: Refresh script modules

### 09.02 Size Management
- **Log rotation**: Limit log files to 100MB per aircraft
- **Backup retention**: Keep last 30 daily backups
- **Git history**: Regular maintenance of repository size
- **Archive strategy**: Move old projects to separate repositories

## 10. Quality Assurance

### 10.01 Validation Checks
- **Syntax validation**: YAML and Lua parsing
- **Reference integrity**: Verify all file dependencies exist
- **Naming consistency**: Enforce naming conventions
- **Content validation**: Check for required fields and values

### 10.02 Testing Structure
```
tests/
├── unit/                       # Individual component tests
├── integration/                # System interaction tests
├── flight/                     # Flight verification tests
└── automation/                 # Automated test scripts
    ├── validate-models.ps1
    ├── test-sync.ps1
    └── check-dependencies.ps1
```