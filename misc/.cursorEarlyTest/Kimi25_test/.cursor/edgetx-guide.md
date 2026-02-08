# EdgeTX Configuration Guide for Cursor

## Overview

EdgeTX is the open-source firmware running on the RadioMaster TX15. This guide provides AI-assisted configuration patterns and best practices.

## EdgeTX File Structure on SD Card

```
D:\ (TX15 SD Card)
├── EEPROM/           # Radio settings and calibration (DO NOT EDIT MANUALLY)
├── FIRMWARE/         # Firmware files (.bin)
├── MODELS/           # Model configurations (.yml, .bin)
│   └── model-name.yml
├── RADIO/            # Radio-wide settings
│   ├── radio.yml     # General settings
│   └── hw_settings.yml
├── SCRIPTS/          # Lua scripts
│   ├── MIXES/        # Custom mixer scripts
│   ├── FUNCTIONS/    # Function scripts
│   ├── TELEMETRY/    # Telemetry display scripts
│   └── TOOLS/        # Utility scripts
├── THEMES/           # Color schemes and layouts
├── SOUNDS/           # Audio files (.wav)
│   ├── en/           # English system sounds
│   └── custom/       # Custom sound packs
├── LOGS/             # Telemetry logs
└── SCREENSHOTS/      # Screen captures

```

## Model Configuration Structure (YAML)

### Basic Model Template

```yaml
---
# WBS: 02.01.01 - Basic Quadcopter Model
modelId: 1
name: "Angel30-3inch"
timer1:
  mode: ON
  start: 0
  minuteBeep: true
  persistent: true
  
# Inputs (Stick movements)
inputs:
  - name: "Ail"
    source: "Ail"
    weight: 100
    expo: 0
  - name: "Ele"
    source: "Ele"
    weight: 100
    expo: 0
  - name: "Thr"
    source: "Thr"
    weight: 100
    expo: 0
  - name: "Rud"
    source: "Rud"
    weight: 100
    expo: 0

# Mixes (Input → Channel mapping)
mixes:
  # Channel 1 - Aileron
  - dest: CH1
    sources:
      - source: Ail
        weight: 100
        
  # Channel 2 - Elevator
  - dest: CH2
    sources:
      - source: Ele
        weight: 100
        
  # Channel 3 - Throttle
  - dest: CH3
    sources:
      - source: Thr
        weight: 100
        
  # Channel 4 - Rudder
  - dest: CH4
    sources:
      - source: Rud
        weight: 100
        
  # Channel 5 - Arm Switch (2-step arming)
  - dest: CH5
    sources:
      - source: SA
        weight: 100
        switch: "!L02"  # Throttle must be low
        
  # Channel 6 - Flight Mode
  - dest: CH6
    sources:
      - source: SB
        weight: 100

# Logical Switches for 2-step arming
logicalSwitches:
  # L01: Arm switch up
  - function: "a>x"
    v1: SA
    v2: 50
    
  # L02: Throttle low (< 5%)
  - function: "a<x"
    v1: Thr
    v2: -95
    
  # L03: Armed condition (SA up AND throttle low)
  - function: AND
    v1: L01
    v2: L02

# Special Functions
specialFunctions:
  # Play sound when armed
  - switch: L03
    function: PLAY_SOUND
    param: "armed.wav"
    
  # Vibrate when armed
  - switch: L03
    function: HAPTIC
    param: 3

# Outputs (Final channel settings)
outputs:
  - ch: 1
    name: "Ail"
    min: -100
    max: 100
    ppmCenter: 0
    
  - ch: 2
    name: "Ele"
    min: -100
    max: 100
    ppmCenter: 0
    
  - ch: 3
    name: "Thr"
    min: -100
    max: 100
    ppmCenter: 0
    
  - ch: 4
    name: "Rud"
    min: -100
    max: 100
    ppmCenter: 0
    
  - ch: 5
    name: "Arm"
    min: -100
    max: 100
    ppmCenter: 0
    
  - ch: 6
    name: "Mode"
    min: -100
    max: 100
    ppmCenter: 0
```

## Flight Mode Implementation

### WBS: 04.01.01 - Quadcopter Flight Modes

```yaml
# Global Variables for flight modes
globalVars:
  - name: "FlightMode"
    value: 0  # 0=Indoor, 1=Outdoor, 2=Normal

# Logical switches for mode detection
logicalSwitches:
  # L10: Indoor mode (SC pos 0)
  - function: "a<x"
    v1: SC
    v2: -50
    
  # L11: Outdoor mode (SC pos 1)
  - function: "a~x"
    v1: SC
    v2: 0
    
  # L12: Normal mode (SC pos 2)
  - function: "a>x"
    v1: SC
    v2: 50

# Flight mode configurations via channel 7
mixes:
  # Channel 7 - Flight mode selector
  - dest: CH7
    sources:
      # Indoor: 25% output
      - source: MAX
        weight: 25
        switch: L10
      # Outdoor: 50% output
      - source: MAX
        weight: 50
        switch: L11
      # Normal: 100% output
      - source: MAX
        weight: 100
        switch: L12

# Rates adjustment per mode (via input scaling)
inputs:
  - name: "Ail"
    source: "Ail"
    weight: 
      - value: 50    # Indoor: 50% rate
        switch: L10
      - value: 75    # Outdoor: 75% rate
        switch: L11
      - value: 100   # Normal: 100% rate
        switch: L12
    expo:
      - value: 50    # Indoor: 50% expo
        switch: L10
      - value: 30    # Outdoor: 30% expo
        switch: L11
      - value: 0     # Normal: 0% expo (use Betaflight)
        switch: L12
```

## Mode2 to Mode4 Switching

### WBS: 04.02.01 - Stick Mode Switcher

```yaml
# Using SF switch for mode switching
# SF↓ (pos 0) = Mode2, SF↑ (pos 1) = Mode4

logicalSwitches:
  # L20: Mode4 active
  - function: "a>x"
    v1: SF
    v2: 0

# Override stick mappings
inputs:
  # In Mode2: Thr on left stick, Ail/Ele on right
  # In Mode4: Ail/Ele on left stick, Thr on right
  
  - name: "Ail"
    source:
      - input: "Ail"     # Mode2: right stick X
        switch: "!L20"
      - input: "Thr"     # Mode4: left stick Y
        switch: "L20"
        
  - name: "Ele"
    source:
      - input: "Ele"     # Mode2: right stick Y
        switch: "!L20"
      - input: "Rud"     # Mode4: left stick X
        switch: "L20"
        
  - name: "Thr"
    source:
      - input: "Thr"     # Mode2: left stick Y
        switch: "!L20"
      - input: "Ail"     # Mode4: right stick X
        switch: "L20"
        
  - name: "Rud"
    source:
      - input: "Rud"     # Mode2: left stick X
        switch: "!L20"
      - input: "Ele"     # Mode4: right stick Y
        switch: "L20"
```

## Fixed Wing Configuration with Reflex V3

### WBS: 02.02.01 - Fixed Wing with Gyro Stabilization

```yaml
# Reflex V3 uses channel 5 for mode selection
# Channel 5 values:
#   < 1300μs = Beginner (full stabilization)
#   1300-1700μs = Advanced (partial stabilization)
#   > 1700μs = Manual (minimal/no stabilization)

mixes:
  # Channel 5 - Reflex V3 mode (DO NOT use for arming)
  - dest: CH5
    sources:
      # Beginner: Low value (~1100μs)
      - source: MAX
        weight: -80
        switch: SD0  # SD position 0
      # Advanced: Mid value (~1500μs)
      - source: MAX
        weight: 0
        switch: SD1  # SD position 1
      # Manual: High value (~1900μs)
      - source: MAX
        weight: 80
        switch: SD2  # SD position 2
        
  # Channel 6 - Throttle cutoff (separate from arming)
  - dest: CH6
    sources:
      - source: SC
        weight: 100
        
  # Channel 7 - Arm switch (not using CH5)
  - dest: CH7
    sources:
      - source: SB
        weight: 100
        switch: "L03"  # Armed condition

# Logical switches for fixed wing arming
logicalSwitches:
  # L01: Arm switch (SB) up
  - function: "a>x"
    v1: SB
    v2: 50
    
  # L02: Throttle low
  - function: "a<x"
    v1: Thr
    v2: -95
    
  # L03: Armed (SB up AND throttle low)
  - function: AND
    v1: L01
    v2: L02
    
  # L04: Throttle cut active (SC down)
  - function: "a<x"
    v1: SC
    v2: -50

# Apply throttle cut
mixes:
  # Throttle mix with cutoff
  - dest: CH3
    sources:
      # Normal throttle
      - source: Thr
        weight: 100
        switch: "!L04"
      # Forced zero when cut active
      - source: MAX
        weight: -100
        switch: L04
    multiplex: REPLACE  # Replace ensures cutoff overrides
```

## Telemetry Configuration

```yaml
telemetry:
  # RSSI (Signal strength)
  - name: "RSSI"
    id: 0x0001
    instance: 0
    
  # Battery voltage
  - name: "RxBt"
    id: 0x0100
    instance: 0
    
  # Current
  - name: "Curr"
    id: 0x0200
    instance: 0
    
# Telemetry screens
telemetryScreens:
  - screen: 1
    lines:
      - line: 0
        source: "RSSI"
        
      - line: 1
        source: "RxBt"
        
      - line: 2
        source: "Curr"

# Voice alerts
specialFunctions:
  # Low RSSI warning
  - switch: "L30"  # RSSI < threshold
    function: PLAY_VALUE
    param: "RSSI"
    repeat: 10  # Every 10 seconds
    
  # Low battery warning
  - switch: "L31"  # Battery < 3.5V
    function: PLAY_SOUND
    param: "lowbat.wav"
    repeat: 5
```

## Curves for Throttle and Expo

```yaml
curves:
  # Throttle curve for smooth low-end
  - name: "Thr-Smooth"
    type: CUSTOM
    points:
      - x: -100
        y: -100
      - x: -50
        y: -60
      - x: 0
        y: 0
      - x: 50
        y: 60
      - x: 100
        y: 100
        
  # Expo curve for gentler center
  - name: "Expo-30"
    type: EXPO
    value: 30

# Apply curves to inputs
inputs:
  - name: "Thr"
    source: "Thr"
    curve: "Thr-Smooth"
    
  - name: "Ail"
    source: "Ail"
    curve: "Expo-30"
```

## Best Practices for AI Assistance

1. **Always validate switch logic**
   - Test all switch positions
   - Verify AND/OR conditions
   - Check for conflicts

2. **Use descriptive names**
   - Inputs: Function (e.g., "Ail", "Ele")
   - Logical switches: Purpose (e.g., "L01-ArmSwitch")
   - Channels: Function (e.g., "CH5-Arm")

3. **Comment complex logic**
   ```yaml
   # L03: Armed state
   # Requires: SA up (L01) AND throttle low (L02)
   # Used for: Safety arming, sound alerts
   - function: AND
     v1: L01
     v2: L02
   ```

4. **Test incrementally**
   - Add one feature at a time
   - Test on bench before flight
   - Verify with EdgeTX companion app

5. **Backup before changes**
   - Copy model file before editing
   - Use version control
   - Document changes in git commits

## Troubleshooting EdgeTX Models

### Issue: Arming not working
1. Check logical switches L01, L02, L03
2. Verify throttle is below threshold (-95)
3. Check SA switch position
4. Review channel 5 output in Companion

### Issue: Controls reversed
1. Check input weights (negative = reversed)
2. Verify output min/max settings
3. Test with Companion simulator

### Issue: Mode switching not working
1. Verify logical switches for each mode
2. Check switch positions
3. Ensure only one mode active at a time

### Issue: Telemetry not showing
1. Verify receiver is sending telemetry (CRSF)
2. Check telemetry sensor discovery
3. Verify sensor IDs match

## EdgeTX Companion App

Use EdgeTX Companion for:
- Editing models on PC (easier than radio screen)
- Testing logical switches and mixes
- Simulation before flight
- Firmware updates
- SD card management

Download: https://edgetx.org

## Resources

- EdgeTX User Manual: https://edgetx.org/edgetx-user-manual/
- Lua Scripting: https://edgetx.org/lua-reference/
- OpenTX University (compatible): https://www.youtube.com/c/OpenTXUniversity
