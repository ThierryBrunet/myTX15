# RC Configuration Package - Installation & Usage Guide

## Package Contents

This ZIP file contains a complete configuration management system for your RadioMaster TX15 and ExpressLRS setup.

### What's Inside

```
rc-config/
├── .cursor/                    # Cursor IDE Integration Files
│   ├── rules.md               # Main Cursor rules for RC configuration
│   ├── edgetx-guide.md        # EdgeTX-specific guidance
│   ├── elrs-guide.md          # ExpressLRS configuration guide
│   └── tx15-sync-skill.md     # Synchronization skill for AI assistants
│
├── tools/                     # PowerShell Utilities
│   └── Sync-TX15Config.ps1   # Configuration sync tool (4 modes)
│
├── docs/                      # Documentation
│   ├── hardware.md            # Complete hardware specifications
│   ├── setup-guide.md         # Step-by-step setup procedures
│   ├── model-templates.md     # Ready-to-use model configurations
│   └── quick-reference.md     # Field reference card
│
└── README.md                  # Project overview and WBS structure
```

---

## Quick Start Installation

### Step 1: Extract Package

1. Extract `rc-config.zip` to your workspace:
   ```
   C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\
   ```

2. You should now have:
   ```
   RadioMaster_TX15\
   ├── rc-config\           # This package
   └── myTX15\              # Your Git repository (create if needed)
       └── EdgeTX\          # EdgeTX configurations
   ```

### Step 2: Set Up Cursor IDE

1. **Option A: Copy to Cursor project folder**
   ```powershell
   # Navigate to your workspace
   cd C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15
   
   # Copy .cursor folder to your project root
   Copy-Item -Path "rc-config\.cursor" -Destination "myTX15\" -Recurse
   ```

2. **Option B: Reference from current location**
   - Open Cursor
   - Open folder: `C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15`
   - In Cursor settings, add as context:
     - `..\rc-config\.cursor\rules.md`
     - `..\rc-config\.cursor\edgetx-guide.md`
     - `..\rc-config\.cursor\elrs-guide.md`

### Step 3: Install PowerShell Tool

1. Copy sync tool to accessible location:
   ```powershell
   # Option A: Copy to your project
   Copy-Item "rc-config\tools\Sync-TX15Config.ps1" -Destination "myTX15\tools\"
   
   # Option B: Add rc-config\tools to PATH
   $env:Path += ";C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\rc-config\tools"
   ```

2. Set execution policy (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Test installation:
   ```powershell
   # Navigate to myTX15 directory
   cd C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15
   
   # Test sync tool (use -WhatIf to preview)
   ..\rc-config\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio -WhatIf
   ```

---

## Using the Configuration System

### With Cursor / AI IDE

Once `.cursor` files are in place:

1. **Ask Cursor to create models**:
   ```
   "Create a model configuration for the Angel30 quadcopter using the DarwinFPV F415 AIO receiver"
   ```
   
   Cursor will:
   - Read the appropriate skill files
   - Follow WBS structure
   - Apply safety requirements
   - Generate proper EdgeTX YAML

2. **Ask Cursor to sync configurations**:
   ```
   "Sync my radio configurations to Git"
   ```
   
   Cursor will:
   - Execute the sync tool
   - Offer to create Git commit
   - Provide summary of changes

3. **Ask for troubleshooting help**:
   ```
   "My receiver won't bind to the TX15"
   ```
   
   Cursor will:
   - Reference the ELRS guide
   - Provide step-by-step solutions
   - Suggest diagnostics

### Manual Usage

#### Sync Radio to Git (Backup)
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
```

#### Sync Git to Radio (Restore/Update)
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
```

#### Mirror Operations (Destructive - Preview First!)
```powershell
# Preview what would be deleted
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf

# Execute after reviewing
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio
```

---

## Documentation Files

### For Setup

**Start here**: `docs/setup-guide.md`
- Complete walkthrough from scratch
- EdgeTX installation
- ExpressLRS configuration
- Git repository setup
- Creating first models

### For Reference

**Hardware specs**: `docs/hardware.md`
- TX15 specifications
- Receiver details (Cyclone, HPXGRC, DarwinFPV)
- Gyro systems (Reflex V3, ICM modules)
- Aircraft specifications

**Quick reference**: `docs/quick-reference.md`
- Emergency procedures
- Pre-flight checklist
- Common ELRS settings
- Troubleshooting quick fixes
- Field repair kit
- Printable reference card

**Model templates**: `docs/model-templates.md`
- Angel30 quadcopter template
- FX707S fixed wing template
- EDGE540 F3P template
- Mode2/Mode4 switching
- Switch assignment reference

---

## Cursor/AI Integration Features

### What the AI Can Do

When properly configured with these files, your AI assistant (Cursor, Claude, etc.) can:

1. **Generate Model Configurations**
   - Follow WBS structure (XX.YY.ZZ numbering)
   - Implement 2-step arming sequences
   - Add flight modes (Indoor/Outdoor/Normal for quads, Beginner/Advanced/Manual for planes)
   - Configure Mode2/Mode4 switching
   - Set up telemetry

2. **Manage Synchronization**
   - Execute sync operations safely
   - Preview changes before destructive operations
   - Create Git commits with proper WBS formatting
   - Suggest appropriate sync modes

3. **Troubleshoot Issues**
   - Reference hardware specifications
   - Provide step-by-step solutions
   - Suggest configuration changes
   - Diagnose binding, range, and telemetry problems

4. **Follow Best Practices**
   - Safety-first approach
   - Proper failsafe configuration
   - Appropriate channel assignments
   - Standard naming conventions

### Skills System

The `.cursor/` folder contains four skill files:

1. **rules.md** - Main rules for RC configuration work
   - File naming conventions
   - WBS numbering pattern
   - Safety requirements
   - Sync operation guidelines

2. **edgetx-guide.md** - EdgeTX-specific guidance
   - Model configuration structure
   - Logical switch patterns
   - Flight mode implementation
   - Telemetry setup

3. **elrs-guide.md** - ExpressLRS configuration
   - Receiver specifications
   - Binding procedures
   - Packet rate configuration
   - Firmware flashing

4. **tx15-sync-skill.md** - Synchronization procedures
   - Sync mode selection
   - Git integration
   - Safety checks
   - Decision trees

---

## Workflow Examples

### Example 1: Creating a New Model

```
You: "Create a model for the Angel30 quadcopter"

Cursor:
1. Reads edgetx-guide.md and model-templates.md
2. Generates YAML configuration with:
   - 2-step arming (SA + throttle low)
   - 3 flight modes (SC switch: Indoor/Outdoor/Normal)
   - Telemetry setup
   - Mode2/Mode4 switching (SF switch)
3. Saves to appropriate location
4. Offers to sync to radio

You: "Yes, sync it"

Cursor:
1. Executes: .\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
2. Shows results
3. Offers to commit to Git
```

### Example 2: Troubleshooting

```
You: "My Cyclone receiver won't bind"

Cursor:
1. Reads elrs-guide.md
2. Checks common issues
3. Provides step-by-step solution:
   - Verify binding phrase matches
   - Re-flash receiver firmware
   - Manual bind procedure
   - Diagnostic steps
```

### Example 3: Backup Before Flying

```
You: "I'm going flying, backup my current config"

Cursor:
1. Executes: .\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
2. Shows files backed up
3. Creates Git commit: "[03.02.02] Pre-flight backup - [date]"
4. Confirms backup complete
```

---

## Customization

### Modify Paths

If your paths differ from defaults:

1. **Edit sync script** (`tools/Sync-TX15Config.ps1`):
   ```powershell
   # Change default parameters at top of script
   [string]$RadioPath = "E:\"  # Your SD card drive
   [string]$GitPath = "D:\RC\TX15\EdgeTX"  # Your git path
   ```

2. **Update Cursor rules** (`.cursor/rules.md`):
   ```markdown
   ## Configuration Paths
   - TX15 SD Card: E:\
   - Git Repository: D:\RC\TX15\EdgeTX
   ```

### Add Your Own Models

1. Create YAML file following template structure
2. Place in appropriate folder:
   - Quads: `models/quadcopters/`
   - Planes: `models/fixed-wings/`
3. Sync to radio:
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
   ```

### Extend Skills

Add custom skills to `.cursor/` folder:
- Create `custom-skill.md`
- Document your specific workflows
- AI will automatically reference when relevant

---

## Safety Reminders

⚠️ **CRITICAL SAFETY RULES** ⚠️

1. **Always implement 2-step arming**
   - Quadcopters: SA switch + throttle low
   - Fixed wings: SB switch + throttle low

2. **Always configure failsafe**
   - Test by turning off TX
   - Verify motors stop (quads) or aircraft enters safe mode (planes)

3. **Always test on bench before flight**
   - Verify control directions
   - Test arming sequence
   - Check flight mode switches
   - Verify throttle cutoff

4. **Always perform range test**
   - Walk at least 100m away
   - Verify RSSI > -90dBm
   - Verify LQ > 90%

5. **Always backup before major changes**
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
   git commit -m "[WBS] Pre-change backup"
   ```

---

## Troubleshooting Package Issues

### Cursor Not Finding Skills

**Problem**: AI not using skill files  
**Solution**:
1. Verify `.cursor` folder in project root
2. Check file permissions (should be readable)
3. Restart Cursor
4. Explicitly reference in prompt: "@rules.md"

### Sync Tool Won't Run

**Problem**: PowerShell execution policy  
**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problem**: Path not found  
**Solution**:
1. Verify TX15 connected and appears as drive
2. Check drive letter (D:, E:, etc.)
3. Update `-RadioPath` parameter

### Git Issues

**Problem**: Git not installed  
**Solution**: Download from https://git-scm.com

**Problem**: Merge conflicts  
**Solution**:
1. Resolve manually in text editor
2. Stage resolved files: `git add .`
3. Commit: `git commit -m "Resolved conflicts"`

---

## Next Steps

1. ✅ Extract package
2. ✅ Set up Cursor integration
3. ✅ Install PowerShell tool
4. ✅ Read `docs/setup-guide.md`
5. ✅ Configure your TX15 (follow WBS 01.00.00)
6. ✅ Create your first model (WBS 02.00.00)
7. ✅ Test thoroughly on bench
8. ✅ Perform range test
9. ✅ First flight!
10. ✅ Regular backups with sync tool

---

## Support & Resources

### Included Documentation
- `README.md` - Project overview
- `docs/setup-guide.md` - Complete setup walkthrough
- `docs/hardware.md` - Hardware specifications
- `docs/model-templates.md` - Model configuration templates
- `docs/quick-reference.md` - Field reference card

### External Resources
- **EdgeTX**: https://edgetx.org
- **ExpressLRS**: https://www.expresslrs.org
- **RadioMaster**: https://www.radiomasterrc.com
- **Betaflight**: https://betaflight.com

### Community Support
- EdgeTX Discord
- ExpressLRS Discord
- RC Groups forums
- Reddit: r/radiocontrol, r/Multicopter

---

## Version Information

**Package Version**: 1.0.0  
**Date**: February 7, 2026  
**Compatibility**:
- RadioMaster TX15 Mark II
- EdgeTX 2.9+
- ExpressLRS 3.x
- Windows 10/11 with PowerShell 5.1+

---

## License & Disclaimer

This configuration package is provided as-is for educational and personal use.

**DISCLAIMER**: RC aircraft can be dangerous. Always:
- Follow local regulations
- Maintain visual line of sight
- Avoid flying over people
- Respect airspace restrictions
- Fly safely and responsibly

The creators of this package are not responsible for any damage, injury, or loss resulting from use of these configurations.

**ALWAYS TEST THOROUGHLY BEFORE FLIGHT**

---

## Feedback & Improvements

This package follows WBS structure for organized development. Future enhancements may include:
- Additional model templates
- Python version of sync tool
- Automated firmware update scripts
- Telemetry log analysis tools
- Configuration backup scheduler

Suggestions welcome!

---

## Quick Command Reference

```powershell
# Most common commands

# Backup radio to Git
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio

# Update radio from Git
.\tools\Sync-TX15Config.ps1 -Mode SyncToRadio

# Preview destructive sync
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf

# Check Git status
cd myTX15\EdgeTX
git status

# Create Git commit
git add -A
git commit -m "[WBS:XX.YY.ZZ] Description"
git push
```

---

Happy Flying! 🚁✈️
