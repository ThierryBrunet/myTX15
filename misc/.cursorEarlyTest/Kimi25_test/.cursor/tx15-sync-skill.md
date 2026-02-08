# TX15 Configuration Synchronization Skill

## Purpose

This skill enables AI assistants (Cursor, VSCode with Claude, etc.) to synchronize RadioMaster TX15 configurations between the SD card and Git repository.

## When to Use This Skill

Trigger this skill when the user wants to:
- Sync configurations from Git to radio
- Sync configurations from radio to Git
- Mirror configurations (with deletions)
- Backup radio configurations
- Restore configurations from Git
- Work with EdgeTX model files
- Manage SD card contents programmatically

## File Structure

### TX15 SD Card Structure (D:\)
```
D:\
├── EEPROM/          # Radio calibration (DO NOT MODIFY)
├── FIRMWARE/        # Firmware binaries
├── MODELS/          # Model configurations (.yml, .bin)
├── SCRIPTS/         # Lua scripts
│   ├── MIXES/
│   ├── FUNCTIONS/
│   ├── TELEMETRY/
│   └── TOOLS/
├── THEMES/          # UI themes
├── SOUNDS/          # Audio files
│   ├── en/
│   └── custom/
├── LOGS/            # Telemetry logs (exclude from git)
└── SCREENSHOTS/     # Screen captures (exclude from git)
```

### Git Repository Structure
```
C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX\
├── MODELS/
├── SCRIPTS/
├── THEMES/
├── SOUNDS/
├── FIRMWARE/
└── README.md
```

## Synchronization Modes

### Mode 1: SyncToRadio (Safe, No Deletions)
**Purpose**: Update radio with new files from Git  
**Behavior**: 
- Copy new files: Git → Radio
- Update modified files: Git → Radio
- Keep existing files on radio
- No deletions

**Use when**:
- Deploying new models to radio
- Updating scripts/themes
- Safe incremental updates

**Command**:
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
```

### Mode 2: SyncFromRadio (Safe, No Deletions)
**Purpose**: Backup radio configurations to Git  
**Behavior**:
- Copy new files: Radio → Git
- Update modified files: Radio → Git
- Keep existing files in Git
- No deletions
- Excludes: LOGS/, SCREENSHOTS/

**Use when**:
- Backing up changes made on radio
- Capturing field configurations
- Incremental backups

**Command**:
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
```

### Mode 3: MirrorToRadio (DESTRUCTIVE)
**Purpose**: Make radio exactly match Git  
**Behavior**:
- Copy all files: Git → Radio
- Update all modified files
- **DELETE files on radio not in Git**
- Full synchronization

**Use when**:
- Restoring clean configuration
- Ensuring radio matches known-good state
- After major Git changes

**Command**:
```powershell
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio -Confirm
```

⚠️ **WARNING**: This deletes files! Use -WhatIf first to preview.

### Mode 4: MirrorFromRadio (DESTRUCTIVE)
**Purpose**: Make Git exactly match radio  
**Behavior**:
- Copy all files: Radio → Git
- Update all modified files
- **DELETE files in Git not on radio**
- Full synchronization

**Use when**:
- Committing all radio changes to Git
- Cleaning up Git repository
- After major radio reconfiguration

**Command**:
```powershell
.\tools\Sync-TX15Config.ps1 -Mode MirrorFromRadio -Confirm
```

⚠️ **WARNING**: This deletes files! Use -WhatIf first to preview.

## AI Assistant Integration

### Decision Tree for AI

```
User wants to sync?
│
├─ "Update radio with my changes"
│  └─ Use: SyncToRadio
│
├─ "Backup my radio settings"
│  └─ Use: SyncFromRadio
│
├─ "Restore radio to match Git"
│  └─ Use: MirrorToRadio (warn about deletions)
│
├─ "Clean up Git to match radio"
│  └─ Use: MirrorFromRadio (warn about deletions)
│
└─ Unclear intent
   └─ Ask user which mode they want
```

### Safety Checks

Before executing sync commands, AI should:

1. **Verify paths exist**:
   ```powershell
   Test-Path "D:\"
   Test-Path "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX"
   ```

2. **Check for uncommitted Git changes** (if syncing TO radio):
   ```powershell
   cd $GitPath
   git status --porcelain
   # If output exists, warn user to commit first
   ```

3. **Use -WhatIf for destructive operations**:
   ```powershell
   # Show preview first
   .\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf
   
   # Then execute if user confirms
   .\Sync-TX15Config.ps1 -Mode MirrorToRadio
   ```

4. **Offer to create Git commit** (after SyncFromRadio):
   ```powershell
   # After successful sync from radio
   cd $GitPath
   git add -A
   git commit -m "[WBS] Sync from radio - description"
   ```

### Example AI Interactions

**Example 1: User created model on radio**
```
User: "I just created a new model on my TX15. Can you back it up to Git?"

AI: I'll sync your radio configurations to Git. This will copy any new or 
modified files from your TX15 to the repository.

[Executes: .\Sync-TX15Config.ps1 -Mode SyncFromRadio]

AI: Successfully synced 3 files:
- MODELS/Angel30-3in.yml (new)
- MODELS/angel30.png (new)
- SOUNDS/custom/armed.wav (modified)

Would you like me to commit these changes to Git?
```

**Example 2: User wants to restore radio**
```
User: "I messed up my radio settings. Can you restore from Git?"

AI: I can restore your radio to match the Git repository, but this will 
DELETE any files on your radio that aren't in Git. Let me show you what 
would change:

[Executes: .\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf]

AI: Preview shows:
- 5 files would be copied from Git
- 2 files would be deleted from radio

Should I proceed with the restore?
```

**Example 3: User made Git changes**
```
User: "I edited the FX707S model in Git. Can you update my radio?"

AI: I'll sync the updated model to your radio.

[Executes: .\Sync-TX15Config.ps1 -Mode SyncToRadio]

AI: Synced 1 file:
- MODELS/FX707S-Wing.yml (updated)

Your radio now has the latest version. Power cycle the TX15 to load the changes.
```

## Git Best Practices

### Commit Message Format

Use WBS references in commit messages:

```
[WBS:XX.YY.ZZ] Description

Examples:
[02.01.01] Add Angel30 quadcopter model
[02.02.01] Update FX707S elevator throw
[03.02.02] Sync from radio - new ELRS settings
[04.01.01] Add indoor flight mode to all quads
```

### .gitignore for EdgeTX

Create `.gitignore` in Git repo:
```gitignore
# Exclude logs and screenshots
LOGS/
SCREENSHOTS/

# Exclude EEPROM (radio-specific calibration)
EEPROM/

# Exclude temporary files
*.tmp
*.bak
~*

# Exclude compiled Lua
*.luac
```

### Branching Strategy

Suggest branches for experimental configs:

```bash
# Main branch: stable, flight-tested configs
git checkout main

# Create branch for new model
git checkout -b model/edge540-f3p

# Work on model...
# Test fly...

# Merge when stable
git checkout main
git merge model/edge540-f3p
```

## Common Issues and Solutions

### Issue: "Radio path not found"
**Cause**: TX15 not connected or wrong drive letter  
**Solution**: 
```powershell
# Find correct drive
Get-PSDrive -PSProvider FileSystem
# Update RadioPath parameter
.\Sync-TX15Config.ps1 -Mode SyncToRadio -RadioPath "E:\"
```

### Issue: "Git path not found"
**Cause**: Incorrect path or OneDrive not synced  
**Solution**: Verify path and update GitPath parameter

### Issue: Sync shows no changes but files were modified
**Cause**: File timestamps not updated  
**Solution**: Touch files to update timestamp, then sync

### Issue: Merge conflicts in Git
**Cause**: Both Git and radio were modified  
**Solution**: 
1. Manually resolve conflicts in Git
2. Use MirrorToRadio to push resolved version

## Integration with Other Tools

### EdgeTX Companion App

AI can suggest using Companion for:
- Visual model editing
- Testing logical switches
- Simulating flight
- Firmware updates

### ExpressLRS Configurator

AI can suggest using Configurator for:
- Receiver firmware updates
- Binding phrase configuration
- Hardware target selection

### Betaflight Configurator

AI can suggest using for:
- Flight controller configuration
- PID tuning
- Receiver setup (CRSF)

## WBS Reference

This skill implements:
- **03.00.00** - Configuration Synchronization
- **03.01.00** - Validation and structure
- **03.02.00** - Safe sync operations
- **03.03.00** - Mirror operations
- **03.04.00** - Git integration

## Script Usage Examples

### Basic Sync (most common)
```powershell
# Update radio with Git changes
.\tools\Sync-TX15Config.ps1 -Mode SyncToRadio

# Backup radio to Git
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
```

### Preview Changes (recommended for mirrors)
```powershell
# Preview what would happen
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf

# Execute after reviewing
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio
```

### Custom Paths
```powershell
.\tools\Sync-TX15Config.ps1 `
  -Mode SyncToRadio `
  -RadioPath "E:\" `
  -GitPath "D:\Backups\TX15"
```

### Verbose Output
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio -Verbose
```

## AI Response Templates

### Template 1: Confirming sync operation
```
I'll sync your [radio/Git] configurations using [Mode].

This operation will:
- [Action 1]
- [Action 2]
- [Action 3]

[Execute command]

Result: [X] files synced successfully.
```

### Template 2: Warning about destructive operation
```
⚠️ WARNING: This operation will DELETE files.

Let me show you what would change:
[Execute with -WhatIf]

Files to be deleted:
- [File 1]
- [File 2]

Should I proceed? (yes/no)
```

### Template 3: Suggesting commit
```
Sync completed successfully. 

I notice you have [X] new/modified files in Git. 
Would you like me to create a commit?

Suggested commit message:
[WBS:XX.YY.ZZ] [Description]

(yes/no)?
```

## Final Checklist

Before executing any sync, AI should verify:
- [ ] Correct mode selected for user's intent
- [ ] Paths exist and are accessible
- [ ] User warned if destructive operation
- [ ] Preview shown for mirror operations
- [ ] User offered Git commit option (if syncing from radio)
- [ ] Success message includes file count and summary
