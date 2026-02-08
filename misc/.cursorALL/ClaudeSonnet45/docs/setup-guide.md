# TX15 & ExpressLRS Setup Guide

## WBS: 01.00.00 - Complete System Setup

This guide walks through the complete setup process from scratch.

---

## Prerequisites

### Required Hardware
- ✅ RadioMaster TX15 transmitter
- ✅ MicroSD card (16GB+ recommended)
- ✅ USB-C cable
- ✅ Windows PC with PowerShell 5.1+
- ✅ At least one ExpressLRS receiver
- ✅ Aircraft (quad or fixed wing)

### Required Software
- ✅ EdgeTX Companion (https://edgetx.org)
- ✅ ExpressLRS Configurator (https://github.com/ExpressLRS/ExpressLRS-Configurator)
- ✅ Git for Windows (https://git-scm.com)
- ✅ PowerShell (included with Windows)
- ✅ Text editor (VS Code, Cursor, or Notepad++)

### Optional Software
- Betaflight Configurator (for quadcopters with FC)
- iNav Configurator (for GPS/autonomous fixed wings)

---

## WBS: 01.01.00 - EdgeTX Installation

### 01.01.01 - Download EdgeTX Firmware

1. Visit: https://edgetx.org
2. Navigate to **Downloads**
3. Select **RadioMaster TX15**
4. Download latest **stable** release (avoid RC/beta unless needed)
5. Save `.bin` file to known location

**Example**: `edgetx-tx15-v2.9.2.bin`

### 01.01.02 - Flash EdgeTX to TX15

**Method 1: Via EdgeTX Companion** (Recommended)

1. Open EdgeTX Companion
2. Connect TX15 via USB-C (radio OFF)
3. Click **Flash Firmware**
4. Select downloaded `.bin` file
5. Click **Write to TX**
6. Wait for completion (LED will blink)
7. Disconnect USB
8. Power on TX15
9. Verify version in: **MENU → SYSTEM → Version**

**Method 2: Via Bootloader** (Manual)

1. Power OFF TX15
2. Hold both trim switches (horizontal) toward center
3. While holding, power ON
4. Release trims when bootloader screen appears
5. Connect USB-C cable
6. TX15 appears as USB drive
7. Copy `.bin` file to root of SD card
8. Safely eject
9. Power cycle TX15
10. Follow on-screen prompts to flash

### 01.01.03 - Initial EdgeTX Configuration

1. Power on TX15
2. Complete first-run wizard:
   - Language: English
   - Voice language: English
   - Owner name: [Your name]
   - Country: [Your country]
   - Default model: [Create blank or skip]

3. Verify settings:
   - **MENU → RADIO SETUP**
   - Date/Time: Set correctly
   - Battery range: 6.0V - 8.4V (2S Li-ion)
   - Battery calibration: Connect voltmeter, adjust if needed
   - Mode: Mode2 (or your preference)
   - Stick calibration: Follow wizard

4. Test gimbals:
   - **MENU → RADIO SETUP → CALIBRATION**
   - Move all sticks to extremes
   - Center all sticks
   - Verify center positions: ~0 (±5)

---

## WBS: 01.02.00 - ExpressLRS Setup

### 01.02.01 - Install ExpressLRS Configurator

1. Download from: https://github.com/ExpressLRS/ExpressLRS-Configurator/releases
2. Install for your platform (Windows: `.exe` installer)
3. Run ExpressLRS Configurator
4. Allow firewall access if prompted

### 01.02.02 - Flash TX15 External Module (if applicable)

**Note**: Only if using external ELRS module. Built-in module? Skip this step.

1. Remove external module from TX15
2. Connect module to PC via USB
3. Open ExpressLRS Configurator
4. Select:
   - **Device category**: ExpressLRS 2.4GHz TX
   - **Device**: [Your module model]
   - **Firmware version**: Latest stable
5. Configure options:
   - **Regulatory domain**: ISM2G4
   - **Binding phrase**: Create unique phrase (e.g., "my_tx15_2024")
   - **Performance options**: Leave default
6. Click **Build & Flash**
7. Wait for completion
8. Disconnect module
9. Re-install in TX15

### 01.02.03 - Configure TX15 External Module Settings

1. Power on TX15
2. Create new model or edit existing:
   - **MENU → MODEL → [MODEL NAME]**
3. Go to **EXTERNAL MODULE**
4. Configure:
   - **Type**: CRSF
   - **Protocol**: ExpressLRS
   - **Receiver number**: 1
   - **Channel range**: 1-16
5. Long-press **SYS** button (on external module)
6. ExpressLRS Lua script appears
7. Configure:
   - **Packet rate**: 250Hz (start here, adjust later)
   - **Telemetry ratio**: 1:8
   - **Switch mode**: Hybrid
   - **Max power**: 100mW (start conservative)
8. Exit back to model screen

### 01.02.04 - Flash Receiver Firmware

#### For Cyclone (PWM or CRSF)

1. Connect receiver to FC or UART adapter
2. If using FC, open Betaflight Configurator
3. Enable **Passthrough** mode
4. Open ExpressLRS Configurator
5. Select:
   - **Device category**: ExpressLRS 2.4GHz RX
   - **Device**: AliExpress_ELRS_2400_RX_PWM (for PWM) or AliExpress_ELRS_2400_RX_CRSF
   - **Firmware version**: Latest stable
6. Configure options:
   - **Binding phrase**: SAME as TX module
   - **Regulatory domain**: ISM2G4
7. Flash via:
   - **Betaflight passthrough** (if connected to FC)
   - **UART** (if direct connection)
8. Wait for completion
9. Receiver LED should blink slowly (searching for TX)

#### For HPXGRC Receiver

Similar process, select device: **HPXGRC_2400_RX**

#### For DarwinFPV F415 AIO

1. Connect F415 to PC via USB
2. Flash Betaflight first (if needed):
   - Open Betaflight Configurator
   - Flash latest Betaflight 4.4+ for F415
3. Then flash ELRS receiver:
   - Enable passthrough in Betaflight
   - Open ExpressLRS Configurator
   - Select device: **DarwinFPV_F415_RX**
   - Use same binding phrase as TX
   - Flash via Betaflight passthrough

### 01.02.05 - Bind Receiver to TX

**Method 1: Binding Phrase** (Recommended)

If TX and RX have same binding phrase, they bind automatically on power-up.

1. Power on TX15
2. Power on receiver
3. Wait 5-10 seconds
4. Receiver LED should go **solid** (bound)
5. Check telemetry on TX15 (RSSI, LQ should appear)

**Method 2: Manual Binding**

If binding phrase not used:

1. Power on TX15
2. Enter model settings
3. Go to **EXTERNAL MODULE → [Bind]**
4. Press bind button on receiver while powering up
5. Receiver LED blinks rapidly
6. Wait until solid LED
7. Exit bind mode on TX15

### 01.02.06 - Verify Connectivity

1. On TX15 telemetry screen:
   - **RSSI**: Should be > -50dBm when close
   - **LQ (Link Quality)**: Should be 100%
   - **RSNR**: Should be positive

2. Move sticks and verify:
   - Betaflight receiver tab shows movement
   - PWM outputs change (measure with servo tester)

3. Range test:
   - Walk 50-100m away
   - RSSI should stay > -100dBm
   - LQ should stay > 90%

---

## WBS: 01.03.00 - Git Repository Setup

### 01.03.01 - Install Git

1. Download Git for Windows: https://git-scm.com
2. Run installer (accept defaults)
3. Verify installation:
   ```powershell
   git --version
   ```

### 01.03.02 - Create Repository

1. Open PowerShell
2. Navigate to workspace:
   ```powershell
   cd C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15
   ```

3. Create repository structure:
   ```powershell
   mkdir myTX15\EdgeTX
   cd myTX15
   git init
   ```

4. Create .gitignore:
   ```powershell
   @"
   # EdgeTX .gitignore
   LOGS/
   SCREENSHOTS/
   EEPROM/
   *.tmp
   *.bak
   "@ | Out-File -FilePath .gitignore -Encoding UTF8
   ```

5. Create README:
   ```powershell
   @"
   # RadioMaster TX15 Configuration
   
   EdgeTX configurations for my TX15 transmitter.
   
   ## Models
   - Angel30 3" Quadcopter
   - FX707S Fixed Wing
   - EDGE540 F3P Aerobatic
   "@ | Out-File -FilePath README.md -Encoding UTF8
   ```

6. Initial commit:
   ```powershell
   git add -A
   git commit -m "[01.03.02] Initial repository setup"
   ```

### 01.03.03 - Copy Initial Configuration from TX15

1. Connect TX15 via USB
2. TX15 appears as drive (usually `D:\`)
3. Run initial sync:
   ```powershell
   # Download sync script from rc-config package
   cd C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15
   
   # Run initial sync
   ..\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
   ```

4. Commit to Git:
   ```powershell
   git add -A
   git commit -m "[01.03.03] Initial sync from TX15"
   ```

---

## WBS: 02.00.00 - Model Configuration

### 02.01.00 - Create First Quadcopter Model (Angel30)

1. Open EdgeTX Companion
2. Open model file or create new model
3. Follow template from: `docs/model-templates.md`
4. Configure:
   - Model name: "Angel30-3in"
   - External module: CRSF / ExpressLRS
   - Inputs: Ail, Ele, Thr, Rud
   - Mixes: Standard AETR + flight modes
   - Logical switches: 2-step arming (L01, L02, L03)
   - Special functions: Arm haptic/sound

5. Save model
6. Sync to TX15:
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
   ```

7. Test on bench:
   - Load model on TX15
   - Verify arming sequence (SA + throttle low)
   - Test flight mode switches (SC)
   - Check telemetry display

### 02.02.00 - Create First Fixed Wing Model (FX707S)

1. Follow similar process for FX707S
2. Use template from `docs/model-templates.md`
3. Key differences:
   - Channel 5: Reflex V3 mode (not arm)
   - Channel 6: Throttle cut
   - Channel 7: Arm status
   - Include throttle curve

4. Bench test with Reflex V3:
   - SD down: Beginner mode (full stabilization)
   - SD mid: Advanced mode
   - SD up: Manual mode
   - Verify gyro activates in each mode

---

## WBS: 03.00.00 - Daily Workflow

### Typical Workflow: Making Changes

1. **Edit model on TX15**:
   - Make changes on radio screen
   - Test fly if needed

2. **Sync to Git**:
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
   ```

3. **Commit changes**:
   ```powershell
   git add -A
   git commit -m "[02.01.01] Adjusted Angel30 rates for indoor flight"
   git push
   ```

### Typical Workflow: Editing in Git

1. **Edit model files** in text editor (VS Code, Cursor)
2. **Sync to TX15**:
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode SyncToRadio
   ```

3. **Test on TX15**:
   - Power cycle radio
   - Load model
   - Verify changes

### Typical Workflow: Restoring from Backup

1. **Check Git history**:
   ```powershell
   git log --oneline
   ```

2. **Checkout old version** (if needed):
   ```powershell
   git checkout <commit-hash>
   ```

3. **Restore to TX15**:
   ```powershell
   .\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio
   ```

---

## WBS: 04.00.00 - Advanced Configuration

### 04.01.00 - Adding Flight Modes

Follow patterns in `docs/model-templates.md`:
- Quadcopters: Indoor / Outdoor / Normal
- Fixed wings: Beginner / Advanced / Manual

### 04.02.00 - Mode2 to Mode4 Switching

Add to any model:
1. Logical switch L20: Detect SF switch
2. Override inputs based on L20 state
3. Test thoroughly before flight

### 04.03.00 - Telemetry Configuration

1. Discover sensors:
   - **MENU → TELEMETRY → Discover new**
   - Move sticks to trigger data
   - Sensors auto-populate

2. Configure screens:
   - **MENU → TELEMETRY → SCREENS**
   - Add RSSI, LQ, battery, etc.

3. Set alarms:
   - Low RSSI: < -100dBm
   - Low LQ: < 50%
   - Low battery: < 3.5V per cell

---

## Troubleshooting

### TX15 won't connect to PC
- Try different USB cable
- Check USB port on TX15 (clean debris)
- Update USB drivers on PC

### Receiver won't bind
- Verify binding phrase matches exactly
- Re-flash receiver with same ELRS version as TX
- Check receiver has power (LED should light)

### No telemetry
- Verify CRSF mode (PWM doesn't support telemetry)
- Check UART configuration in Betaflight
- Ensure baud rate: 420000

### Poor range
- Lower packet rate (250Hz → 150Hz → 50Hz)
- Increase TX power (100mW → 250mW)
- Check antenna orientation (perpendicular to flight path)
- Enable dynamic power

### High latency
- Increase packet rate (250Hz → 500Hz)
- Reduce telemetry ratio (1:8 → 1:16)
- Ensure no interference

---

## Pre-Flight Checklist

### Every Flight
- [ ] TX15 battery charged (> 7.0V)
- [ ] Aircraft battery charged
- [ ] Receiver bound (solid LED)
- [ ] RSSI > -50dBm when close
- [ ] Link quality = 100% when close
- [ ] All sticks centered
- [ ] Arming sequence works (can arm and disarm)
- [ ] Throttle cutoff works
- [ ] Flight mode switches work
- [ ] Failsafe test (turn off TX, verify disarm)

### New Model / After Changes
- [ ] Control surface directions correct
- [ ] Control throws appropriate
- [ ] CG (center of gravity) correct
- [ ] All screws/bolts tight
- [ ] Props balanced and secure
- [ ] Range test (100m minimum)

---

## Backup Strategy

### Daily (if actively flying)
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
git commit -am "Daily backup"
```

### Weekly (document changes)
```powershell
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
git add -A
git commit -m "[WBS] Description of changes"
git push
```

### Before Major Changes
```powershell
# Create branch
git checkout -b experimental/new-feature

# Make changes...

# Test...

# Merge if successful
git checkout main
git merge experimental/new-feature
```

---

## Next Steps

1. ✅ Complete WBS 01.00.00 (System Setup)
2. ✅ Create first model (WBS 02.00.00)
3. ✅ Bench test thoroughly
4. ✅ Configure failsafe
5. ✅ Range test
6. ✅ First flight (beginner mode!)
7. ✅ Fine-tune settings
8. ✅ Backup to Git

---

## Resources

- **EdgeTX Manual**: https://edgetx.org/edgetx-user-manual/
- **ExpressLRS Docs**: https://www.expresslrs.org/
- **RadioMaster Support**: https://www.radiomasterrc.com/pages/support
- **Betaflight Docs**: https://betaflight.com/docs/
- **OpenTX University** (EdgeTX compatible): https://www.youtube.com/c/OpenTXUniversity

---

## Support

For issues with:
- **EdgeTX**: EdgeTX Discord or forums
- **ExpressLRS**: ExpressLRS Discord
- **RadioMaster TX15**: RadioMaster support page
- **This configuration**: Review docs in `docs/` folder

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-02-07 | Initial setup guide |
