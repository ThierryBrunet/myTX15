# TX15 Quick Reference Card

## Emergency Procedures

### Lost Model
1. Switch to beginner/angle mode (if available)
2. Reduce throttle
3. Let stabilization system recover
4. Activate failsafe if needed (power off TX)

### Fly Away
1. Immediately power off TX
2. Failsafe will activate
3. Quad: Motors stop (DROP mode)
4. Plane: Should circle or glide (if configured)

### No Control
1. Check TX battery
2. Verify model selected
3. Check RSSI/LQ on telemetry
4. If RSSI < -100dBm: Move closer
5. If still no control: Activate failsafe

---

## TX15 Controls Quick Reference

### Sticks (Mode 2)
```
Left Stick:              Right Stick:
    ↑                        ↑
    Throttle                 Elevator (Pitch)
    ↓                        ↓

← Rudder    Yaw →        ← Aileron   Roll →
    (Left/Right)             (Left/Right)
```

### Standard Switch Assignments

| Switch | Default Function | Positions |
|--------|------------------|-----------|
| SA | Quad: Arm | ↓ Disarm, ↑ Arm |
| SB | Plane: Arm / Quad: Flight Mode | ↓ Disarm/Angle, mid, ↑ Arm/Acro |
| SC | Flight Mode / Throttle Cut | ↓ Indoor/Cut, mid Outdoor, ↑ Normal |
| SD | Gyro Mode / Rates | ↓ Beginner/Low, mid Advanced, ↑ Manual/High |
| SE | Trim Capture | Momentary |
| SF | Mode2/Mode4 Toggle | ↓ Mode2, ↑ Mode4 |

### Critical Key Combos

| Action | Method |
|--------|--------|
| **Enter Bootloader** | Hold both horizontal trims center + power on |
| **Calibrate Sticks** | MENU → RADIO SETUP → CALIBRATION |
| **Access Model Menu** | Long press SYS or MENU button |
| **ELRS Lua Script** | Long press SYS on external module |
| **Emergency Stop** | Power off TX (activates failsafe) |

---

## Pre-Flight Checklist (Printable)

### TX15 Check
- [ ] Battery > 7.0V
- [ ] Correct model selected
- [ ] Sticks centered (±5)
- [ ] Switches in known positions
- [ ] Timers reset (if using)

### Receiver Check
- [ ] Bound (solid LED)
- [ ] RSSI > -50dBm
- [ ] Link Quality = 100%
- [ ] Telemetry working (battery voltage shows)

### Aircraft Check (Quad)
- [ ] Battery charged and secure
- [ ] Props secure (correct rotation)
- [ ] Camera angle appropriate
- [ ] VTX powered (if FPV)
- [ ] No loose wires

### Aircraft Check (Plane)
- [ ] Battery charged and secure
- [ ] CG correct (balances at 25-30% chord)
- [ ] Control surfaces move correctly:
  - [ ] Aileron: Stick right → Right aileron UP
  - [ ] Elevator: Stick back → Elevator UP
  - [ ] Rudder: Stick right → Rudder RIGHT
- [ ] Gyro mode set correctly
- [ ] Throttle cut working

### Function Checks
- [ ] Arming sequence works
- [ ] Can disarm successfully
- [ ] Throttle cutoff works
- [ ] Flight mode switches work
- [ ] Failsafe test passed:
  - [ ] Turn off TX
  - [ ] Quad: Motors stop within 2 sec
  - [ ] Plane: Holds last position or activates failsafe mode

### Range Check
- [ ] Walk 100m away
- [ ] RSSI > -90dBm
- [ ] Link Quality > 90%
- [ ] Full control maintained

---

## Common ELRS Settings

### Packet Rates (2.4GHz)

| Rate | Range | Latency | Use Case |
|------|-------|---------|----------|
| 500Hz | 2km | 2ms | Racing, close range |
| 250Hz | 5km | 4ms | Freestyle, general (RECOMMENDED) |
| 150Hz | 10km | 6.7ms | Long range, cruising |
| 50Hz | 30km | 20ms | Ultra long range |

### TX Power Levels

| Power | Use Case |
|-------|----------|
| 10mW | Indoor, very close |
| 25mW | Small park |
| 50mW | Large park |
| 100mW | General flying (RECOMMENDED) |
| 250mW | Long range |
| 500mW+ | Extended range (needs cooling) |

### Telemetry Ratio

| Ratio | RC Bandwidth | Telemetry | Use Case |
|-------|--------------|-----------|----------|
| 1:2 | Lower | High | When telemetry critical |
| 1:4 | Medium | Medium | Balanced |
| 1:8 | Higher | Lower | General (RECOMMENDED) |
| 1:16 | Highest | Minimal | Racing, lowest latency |

---

## Betaflight CLI Quick Commands (Quads)

### View Current Settings
```
dump
```

### Configure ELRS Receiver
```
set serialrx_provider = CRSF
set serialrx_inverted = OFF
save
```

### Configure Arming
```
set small_angle = 180
save
```

### Configure Failsafe
```
set failsafe_procedure = DROP
set failsafe_delay = 15
set failsafe_throttle = 1000
save
```

### View/Set Flight Modes
```
# View current mode configuration
get mode_range

# Set mode on channel 6
# AUX2 (channel 6): 900-1300 = Angle, 1300-1700 = Horizon, 1700-2100 = Acro
aux 0 0 0 900 1300 0 0    # Angle mode on AUX2 low
aux 0 1 0 1300 1700 0 0   # Horizon on AUX2 mid
aux 0 2 0 1700 2100 0 0   # Acro on AUX2 high

save
```

---

## Sync Commands

### Safe Sync (No Deletions)
```powershell
# Git → Radio (update radio)
.\tools\Sync-TX15Config.ps1 -Mode SyncToRadio

# Radio → Git (backup)
.\tools\Sync-TX15Config.ps1 -Mode SyncFromRadio
```

### Mirror Sync (WITH Deletions)
```powershell
# Preview first
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio -WhatIf

# Execute
.\tools\Sync-TX15Config.ps1 -Mode MirrorToRadio
```

---

## Troubleshooting Quick Fixes

### No Bind
1. Verify binding phrase matches (TX & RX)
2. Re-flash receiver
3. Power cycle both TX and RX
4. Try manual bind mode

### Poor Range / Link Quality
1. Lower packet rate (500→250→150Hz)
2. Increase TX power
3. Check antenna position (perpendicular to flight)
4. Reduce interference (turn off WiFi nearby)

### Telemetry Not Working
1. Verify CRSF mode (not PWM)
2. Check Betaflight UART config
3. Verify baud rate: 420000
4. Rediscover sensors on TX

### Reversed Controls
1. Check output tab in Betaflight
2. Reverse in Betaflight (NOT radio)
3. For planes: May need to reverse in radio

### Won't Arm
**Quadcopters**:
1. Check accelerometer calibration
2. Verify `small_angle = 180` in Betaflight
3. Ensure throttle < 5%
4. Check arm switch position

**Planes**:
1. Verify throttle low
2. Check arm switch position (SB up)
3. Verify logical switch L03 active

### High Latency / Slow Response
1. Increase packet rate (250→500Hz)
2. Reduce telemetry ratio (1:8 → 1:16)
3. Update ELRS firmware (TX & RX)

---

## Field Repair Kit

### Essential Tools
- [ ] Hex drivers (1.5mm, 2.0mm, 2.5mm)
- [ ] Phillips screwdriver (small)
- [ ] Zip ties (assorted)
- [ ] Electrical tape
- [ ] CA glue (thin & medium)
- [ ] Soldering iron (if possible)

### Spare Parts
- [ ] Props (multiple sets)
- [ ] Battery straps
- [ ] Receiver antenna
- [ ] Servo arms
- [ ] Control horns
- [ ] Spare battery (TX18650s)

### Electronics
- [ ] USB cable (TX15)
- [ ] Receiver (spare)
- [ ] Battery charger
- [ ] Volt meter

---

## Contact Information

### Project Structure
```
rc-config/
├── .cursor/          # IDE rules and guides
├── tools/            # PowerShell sync tools
├── docs/             # Documentation
├── models/           # Model configurations
└── README.md         # Project overview
```

### Git Repository
```
C:\Users\thier\OneDrive\Workspaces\ExpressLRS\
  RadioMaster_TX15\myTX15\EdgeTX
```

### TX15 SD Card
```
D:\ (when connected via USB)
```

---

## Useful Links

| Resource | URL |
|----------|-----|
| EdgeTX Manual | https://edgetx.org/edgetx-user-manual/ |
| EdgeTX Companion | https://edgetx.org |
| ExpressLRS Docs | https://www.expresslrs.org/ |
| ExpressLRS Config | https://github.com/ExpressLRS/ExpressLRS-Configurator |
| RadioMaster Support | https://www.radiomasterrc.com/pages/support |
| Betaflight | https://betaflight.com/docs/ |
| OpenTX University | https://www.youtube.com/c/OpenTXUniversity |

---

## WBS Reference

| Code | Description |
|------|-------------|
| 01.00.00 | System Setup |
| 02.00.00 | Model Configuration |
| 03.00.00 | Synchronization |
| 04.00.00 | Advanced Features |

For detailed WBS, see `README.md`

---

## Notes Section (Write Your Settings)

**My Binding Phrase**: ____________________

**Packet Rate**: ______ Hz

**TX Power**: ______ mW

**Telemetry Ratio**: 1:______

**Model 1**: ____________________
- Type: Quad / Plane
- Battery: ____ S ______ mAh
- Notes: ____________________

**Model 2**: ____________________
- Type: Quad / Plane
- Battery: ____ S ______ mAh
- Notes: ____________________

**Model 3**: ____________________
- Type: Quad / Plane  
- Battery: ____ S ______ mAh
- Notes: ____________________

---

## Version

Document Version: 1.0.0  
Date: 2024-02-07  
System: RadioMaster TX15 + EdgeTX + ExpressLRS
