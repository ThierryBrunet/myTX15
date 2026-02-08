# Model Configuration Templates

## WBS: 02.00.00 - Model Configurations

This document provides ready-to-use templates for creating model configurations in EdgeTX.

---

## WBS: 02.01.00 - Quadcopter Templates

### 02.01.01 - Angel30 3" Quadcopter (DarwinFPV F415 AIO)

```yaml
---
# Angel30 3" FPV Quadcopter
# WBS: 02.01.01
# Receiver: DarwinFPV F415 AIO (integrated ELRS)
# Flight Controller: Betaflight

modelId: 1
name: "Angel30-3in"
bitmap: "angel30.png"

# Timer
timer1:
  mode: THs
  start: 0
  minuteBeep: true
  persistent: true

# External Module (ELRS)
externalModule:
  type: CRSF
  protocol: ExpressLRS
  channelsCount: 16
  
# Inputs
inputs:
  - id: 0
    name: "Ail"
    source: "Ail"
    
  - id: 1
    name: "Ele"
    source: "Ele"
    
  - id: 2
    name: "Thr"
    source: "Thr"
    
  - id: 3
    name: "Rud"
    source: "Rud"

# Logical Switches
logicalSwitches:
  # L01: Arm switch UP (SA)
  - id: 0
    func: "a>x"
    v1: SA
    v2: 50
    
  # L02: Throttle LOW (< 5%)
  - id: 1
    func: "a<x"
    v1: Thr
    v2: -95
    
  # L03: ARMED condition (SA up AND throttle low)
  - id: 2
    func: AND
    v1: L01
    v2: L02
    
  # L10: Indoor mode (SC pos 0 - down)
  - id: 9
    func: "a<x"
    v1: SC
    v2: -33
    
  # L11: Outdoor mode (SC pos 1 - middle)
  - id: 10
    func: "a~x"
    v1: SC
    v2: 0
    v3: 33
    
  # L12: Normal mode (SC pos 2 - up)
  - id: 11
    func: "a>x"
    v1: SC
    v2: 33
    
  # L20: Mode4 active (SF up)
  - id: 19
    func: "a>x"
    v1: SF
    v2: 0

# Special Functions
specialFunctions:
  # Haptic feedback when armed
  - switch: L03
    func: HAPTIC
    param: 2
    
  # Play sound when armed
  - switch: L03
    func: PLAY_TRACK
    param: "armed.wav"
    
  # Vario on S1 slider for throttle indication
  - switch: ON
    func: VARIO
    param: Thr

# Mixes
mixes:
  # CH1 - Aileron (with rate limiting based on flight mode)
  - id: 0
    dest: CH1
    sources:
      - weight: 50
        source: Ail
        switch: L10  # Indoor: 50%
      - weight: 75
        source: Ail
        switch: L11  # Outdoor: 75%
      - weight: 100
        source: Ail
        switch: L12  # Normal: 100%
    
  # CH2 - Elevator (with rate limiting based on flight mode)
  - id: 1
    dest: CH2
    sources:
      - weight: 50
        source: Ele
        switch: L10  # Indoor: 50%
      - weight: 75
        source: Ele
        switch: L11  # Outdoor: 75%
      - weight: 100
        source: Ele
        switch: L12  # Normal: 100%
    
  # CH3 - Throttle (with limiting based on flight mode)
  - id: 2
    dest: CH3
    sources:
      - weight: 50
        source: Thr
        switch: L10  # Indoor: 50% max
      - weight: 75
        source: Thr
        switch: L11  # Outdoor: 75% max
      - weight: 100
        source: Thr
        switch: L12  # Normal: 100% max
    
  # CH4 - Rudder (with rate limiting based on flight mode)
  - id: 3
    dest: CH4
    sources:
      - weight: 50
        source: Rud
        switch: L10  # Indoor: 50%
      - weight: 75
        source: Rud
        switch: L11  # Outdoor: 75%
      - weight: 100
        source: Rud
        switch: L12  # Normal: 100%
    
  # CH5 - ARM (2-step: SA up AND throttle low)
  - id: 4
    dest: CH5
    sources:
      - weight: 100
        source: MAX
        switch: L03  # Armed condition
    
  # CH6 - Flight mode (angle/horizon/acro from Betaflight)
  - id: 5
    dest: CH6
    sources:
      - weight: -100
        source: MAX
        switch: SB0  # SB down = Angle mode
      - weight: 0
        source: MAX
        switch: SB1  # SB mid = Horizon mode
      - weight: 100
        source: MAX
        switch: SB2  # SB up = Acro mode
    
  # CH7 - Rate profile selector (maps to flight mode rates)
  - id: 6
    dest: CH7
    sources:
      - weight: -100
        source: MAX
        switch: L10  # Indoor
      - weight: 0
        source: MAX
        switch: L11  # Outdoor
      - weight: 100
        source: MAX
        switch: L12  # Normal

# Outputs
outputs:
  - id: 0
    name: "Ail"
    min: -100
    max: 100
    
  - id: 1
    name: "Ele"
    min: -100
    max: 100
    
  - id: 2
    name: "Thr"
    min: -100
    max: 100
    
  - id: 3
    name: "Rud"
    min: -100
    max: 100
    
  - id: 4
    name: "Arm"
    min: -100
    max: 100
    
  - id: 5
    name: "Mode"
    min: -100
    max: 100
    
  - id: 6
    name: "Rate"
    min: -100
    max: 100

# Telemetry
telemetry:
  - id: 0
    name: "RSSI"
  - id: 1
    name: "RQly"
  - id: 2
    name: "RSNR"
  - id: 3
    name: "RxBt"
  - id: 4
    name: "Curr"
  - id: 5
    name: "Capa"

# Telemetry Screens
telemetryScreens:
  - screen: 1
    items:
      - line: 0
        label: "RSSI"
        source: "RSSI"
      - line: 1
        label: "LQ"
        source: "RQly"
      - line: 2
        label: "Batt"
        source: "RxBt"
```

**Betaflight Configuration** (via CLI):
```
# 02.01.01 - Angel30 Betaflight Settings

# Receiver
set serialrx_provider = CRSF
set serialrx_inverted = OFF

# Arming
set arm_switch_channel = 5
set small_angle = 180

# Flight modes (based on channel 6)
# Angle mode: < 1300μs
# Horizon mode: 1300-1700μs  
# Acro mode: > 1700μs

# Rate profiles (based on channel 7)
# Profile 0 (Indoor): < 1300μs - 200°/s, RC rate 1.0
# Profile 1 (Outdoor): 1300-1700μs - 400°/s, RC rate 1.2
# Profile 2 (Normal): > 1700μs - 700°/s, RC rate 1.5

# Failsafe
set failsafe_procedure = DROP
set failsafe_delay = 15
set failsafe_throttle = 1000

save
```

---

## WBS: 02.02.00 - Fixed Wing Templates

### 02.02.01 - FX707S Fixed Wing (Cyclone PWM + Reflex V3)

```yaml
---
# Flying Bear FX707S Fixed Wing
# WBS: 02.02.01
# Receiver: Cyclone ELRS PWM 7CH
# Gyro: Reflex V3

modelId: 2
name: "FX707S-Wing"
bitmap: "fx707s.png"

# Timer
timer1:
  mode: THs
  start: 0
  minuteBeep: true
  persistent: true

# External Module (ELRS)
externalModule:
  type: PPM
  protocol: ExpressLRS
  channelsCount: 8

# Inputs
inputs:
  - id: 0
    name: "Ail"
    source: "Ail"
    
  - id: 1
    name: "Ele"
    source: "Ele"
    
  - id: 2
    name: "Thr"
    source: "Thr"
    
  - id: 3
    name: "Rud"
    source: "Rud"

# Logical Switches
logicalSwitches:
  # L01: Arm switch UP (SB)
  - id: 0
    func: "a>x"
    v1: SB
    v2: 50
    
  # L02: Throttle LOW
  - id: 1
    func: "a<x"
    v1: Thr
    v2: -95
    
  # L03: ARMED (SB up AND throttle low)
  - id: 2
    func: AND
    v1: L01
    v2: L02
    
  # L04: Throttle cut active (SC down)
  - id: 3
    func: "a<x"
    v1: SC
    v2: -33
    
  # L20: Mode4 active (SF up)
  - id: 19
    func: "a>x"
    v1: SF
    v2: 0

# Special Functions
specialFunctions:
  # Haptic when armed
  - switch: L03
    func: HAPTIC
    param: 2
    
  # Play sound when armed
  - switch: L03
    func: PLAY_TRACK
    param: "armed.wav"
    
  # Play sound when throttle cut active
  - switch: L04
    func: PLAY_TRACK
    param: "thr-cut.wav"

# Curves
curves:
  # Throttle curve - smooth takeoff
  - id: 0
    name: "Thr-Smooth"
    type: CUSTOM
    points:
      - x: -100
        y: -100
      - x: -50
        y: -70
      - x: 0
        y: 0
      - x: 50
        y: 70
      - x: 100
        y: 100

# Mixes
mixes:
  # CH1 - Aileron
  - id: 0
    dest: CH1
    sources:
      - weight: 100
        source: Ail
    
  # CH2 - Elevator (with slight up trim for stability)
  - id: 1
    dest: CH2
    sources:
      - weight: 100
        source: Ele
      - weight: 5
        source: MAX  # Slight up trim
    
  # CH3 - Throttle (with cut and smooth curve)
  - id: 2
    dest: CH3
    sources:
      - weight: 100
        source: Thr
        curve: "Thr-Smooth"
        switch: "!L04"  # Normal throttle when cut inactive
      - weight: -100
        source: MAX
        switch: L04  # Force zero when cut active
    multiplex: REPLACE
    
  # CH4 - Rudder
  - id: 3
    dest: CH4
    sources:
      - weight: 100
        source: Rud
    
  # CH5 - Reflex V3 Mode
  - id: 4
    dest: CH5
    sources:
      - weight: -80
        source: MAX
        switch: SD0  # SD down = Beginner (<1300μs)
      - weight: 0
        source: MAX
        switch: SD1  # SD mid = Advanced (~1500μs)
      - weight: 80
        source: MAX
        switch: SD2  # SD up = Manual (>1700μs)
    
  # CH6 - Throttle cut indicator (separate from CH3)
  - id: 5
    dest: CH6
    sources:
      - weight: 100
        source: SC
    
  # CH7 - Arm status (not using CH5 which is for Reflex)
  - id: 6
    dest: CH7
    sources:
      - weight: 100
        source: MAX
        switch: L03

# Outputs
outputs:
  - id: 0
    name: "Ail"
    min: -100
    max: 100
    
  - id: 1
    name: "Ele"
    min: -100
    max: 100
    
  - id: 2
    name: "Thr"
    min: -100
    max: 100
    
  - id: 3
    name: "Rud"
    min: -100
    max: 100
    
  - id: 4
    name: "Gyro"  # Reflex mode
    min: -100
    max: 100
    
  - id: 5
    name: "ThrCut"
    min: -100
    max: 100
    
  - id: 6
    name: "Armed"
    min: -100
    max: 100

# Telemetry
telemetry:
  - id: 0
    name: "RSSI"
  - id: 1
    name: "RQly"

# Telemetry Screens
telemetryScreens:
  - screen: 1
    items:
      - line: 0
        label: "RSSI"
        source: "RSSI"
      - line: 1
        label: "Link"
        source: "RQly"
      - line: 2
        label: "Mode"
        source: "SD"
```

**Reflex V3 Mode Reference**:
- **SD Down** (Beginner): Full stabilization + auto-level
- **SD Middle** (Advanced): Rate mode, partial stabilization
- **SD Up** (Manual): Minimal/no gyro assistance

**Control Surface Throws** (measure at servo arm):
- Aileron: ±15mm (100% throw)
- Elevator: ±12mm (100% throw)
- Rudder: ±20mm (100% throw)

**CG Location**: 25-30% of wing chord from leading edge

---

### 02.02.02 - EDGE540 F3P Aerobatic (Cyclone PWM)

```yaml
---
# EDGE540 EPP F3P Aerobatic
# WBS: 02.02.02
# Receiver: Cyclone ELRS PWM 7CH
# Type: 3D aerobatic, precision flying

modelId: 3
name: "EDGE540-F3P"
bitmap: "edge540.png"

# Timer
timer1:
  mode: THs
  start: 0
  minuteBeep: true
  persistent: true

# External Module (ELRS)
externalModule:
  type: PPM
  protocol: ExpressLRS
  channelsCount: 8

# Inputs (high expo for precision)
inputs:
  - id: 0
    name: "Ail"
    source: "Ail"
    weight: 100
    expo: 40  # High expo for center precision
    
  - id: 1
    name: "Ele"
    source: "Ele"
    weight: 100
    expo: 40
    
  - id: 2
    name: "Thr"
    source: "Thr"
    weight: 100
    
  - id: 3
    name: "Rud"
    source: "Rud"
    weight: 100
    expo: 40

# Logical Switches
logicalSwitches:
  # L01: Arm switch UP (SB)
  - id: 0
    func: "a>x"
    v1: SB
    v2: 50
    
  # L02: Throttle LOW
  - id: 1
    func: "a<x"
    v1: Thr
    v2: -95
    
  # L03: ARMED
  - id: 2
    func: AND
    v1: L01
    v2: L02
    
  # L04: Throttle hold (SC down)
  - id: 3
    func: "a<x"
    v1: SC
    v2: -33
    
  # L05: High rate (SD up)
  - id: 4
    func: "a>x"
    v1: SD
    v2: 33
    
  # L06: Low rate (SD down) - for precision
  - id: 5
    func: "a<x"
    v1: SD
    v2: -33
    
  # L20: Mode4 active
  - id: 19
    func: "a>x"
    v1: SF
    v2: 0

# Special Functions
specialFunctions:
  # Haptic when armed
  - switch: L03
    func: HAPTIC
    param: 2

# Curves
curves:
  # Throttle curve for 3D (allows prop hanging)
  - id: 0
    name: "Thr-3D"
    type: CUSTOM
    points:
      - x: -100
        y: -50  # Some reverse
      - x: -50
        y: -25
      - x: 0
        y: 0    # Motor off
      - x: 50
        y: 50
      - x: 100
        y: 100  # Full forward

# Mixes
mixes:
  # CH1 - Right Aileron (dual servos for precision)
  - id: 0
    dest: CH1
    sources:
      - weight: 60
        source: Ail
        switch: L06  # Low rate
      - weight: 100
        source: Ail
        switch: "!L05 & !L06"  # Medium rate (SD mid)
      - weight: 125
        source: Ail
        switch: L05  # High rate (3D maneuvers)
    
  # CH2 - Elevator
  - id: 1
    dest: CH2
    sources:
      - weight: 60
        source: Ele
        switch: L06
      - weight: 100
        source: Ele
        switch: "!L05 & !L06"
      - weight: 125
        source: Ele
        switch: L05
    
  # CH3 - Throttle (with hold and 3D curve)
  - id: 2
    dest: CH3
    sources:
      - weight: 100
        source: Thr
        curve: "Thr-3D"
        switch: "!L04"
      - weight: 0
        source: MAX
        switch: L04  # Throttle hold
    
  # CH4 - Rudder
  - id: 3
    dest: CH4
    sources:
      - weight: 60
        source: Rud
        switch: L06
      - weight: 100
        source: Rud
        switch: "!L05 & !L06"
      - weight: 125
        source: Rud
        switch: L05
    
  # CH5 - Left Aileron (reversed, for dual aileron)
  - id: 4
    dest: CH5
    sources:
      - weight: -60
        source: Ail
        switch: L06
      - weight: -100
        source: Ail
        switch: "!L05 & !L06"
      - weight: -125
        source: Ail
        switch: L05
    
  # CH6 - Rate/Expo switch indicator
  - id: 5
    dest: CH6
    sources:
      - weight: 100
        source: SD
    
  # CH7 - Arm status
  - id: 6
    dest: CH7
    sources:
      - weight: 100
        source: MAX
        switch: L03

# Outputs (large throws for 3D)
outputs:
  - id: 0
    name: "AilR"
    min: -125  # Allow >100% for 3D
    max: 125
    
  - id: 1
    name: "Ele"
    min: -125
    max: 125
    
  - id: 2
    name: "Thr"
    min: -100
    max: 100
    
  - id: 3
    name: "Rud"
    min: -125
    max: 125
    
  - id: 4
    name: "AilL"
    min: -125
    max: 125
    
  - id: 5
    name: "Rate"
    min: -100
    max: 100
    
  - id: 6
    name: "Armed"
    min: -100
    max: 100
```

**Control Surface Throws** (F3P competitive setup):
- Aileron: ±35mm (high rate), ±20mm (low rate)
- Elevator: ±30mm (high rate), ±18mm (low rate)
- Rudder: ±40mm (high rate), ±25mm (low rate)

**CG Location**: 60-65mm from leading edge (nose-heavy for stability)

**Rate Switch Usage**:
- **Low Rate** (SD down): Precision maneuvers, landings
- **Medium Rate** (SD middle): General flying
- **High Rate** (SD up): 3D aerobatics (harriers, hovers, etc.)

---

## Mode2 to Mode4 Switch Implementation

### WBS: 04.02.01 - Add to ANY Model

Add these logical switches and input overrides to any model to enable Mode2/Mode4 switching via SF switch:

```yaml
# Logical switch for Mode4 detection
logicalSwitches:
  - id: 19  # L20
    func: "a>x"
    v1: SF
    v2: 0  # SF up = Mode4

# Override inputs based on stick mode
inputs:
  - id: 0  # Aileron
    name: "Ail"
    source:
      - input: "Ail"      # Mode2: Right stick X-axis
        switch: "!L20"
      - input: "Thr"      # Mode4: Left stick Y-axis  
        switch: "L20"
        
  - id: 1  # Elevator
    name: "Ele"
    source:
      - input: "Ele"      # Mode2: Right stick Y-axis
        switch: "!L20"
      - input: "Rud"      # Mode4: Left stick X-axis
        switch: "L20"
        
  - id: 2  # Throttle
    name: "Thr"
    source:
      - input: "Thr"      # Mode2: Left stick Y-axis
        switch: "!L20"
      - input: "Ail"      # Mode4: Right stick X-axis
        switch: "L20"
        
  - id: 3  # Rudder
    name: "Rud"
    source:
      - input: "Rud"      # Mode2: Left stick X-axis
        switch: "!L20"
      - input: "Ele"      # Mode4: Right stick Y-axis
        switch: "L20"
```

**Usage**: 
- SF down = Mode2 (standard)
- SF up = Mode4 (stick mode change)

**Note**: This can be added to ANY model template above by inserting the L20 logical switch and modifying the input section.

---

## Quick Reference: Switch Assignments

### Standard Switch Usage Across All Models

| Switch | Function | Positions | Notes |
|--------|----------|-----------|-------|
| **SA** | Arm (quads) | ↓=Disarm, ↑=Arm | 2-step with throttle check |
| **SB** | Arm (planes) OR Flight mode (quads) | ↓=Disarm, mid=X, ↑=Arm | Depends on model type |
| **SC** | Flight mode (quads) OR Throttle cut (planes) | ↓=Indoor/Cut, mid=Outdoor, ↑=Normal | Rate limiter or cut |
| **SD** | Gyro mode (planes) OR Rate (F3P) | ↓=Beginner/Low, mid=Advanced/Mid, ↑=Manual/High | Gyro or rate switch |
| **SE** | Trim capture | Momentary | Press to save trims |
| **SF** | Mode2/Mode4 | ↓=Mode2, ↑=Mode4 | Stick mode change |
| **S1** | Throttle monitor | Slider | Vario feedback |
| **S2** | User defined | Slider | Available |

---

## Notes

1. **All templates include**:
   - 2-step arming sequences
   - Failsafe configurations
   - Mode2/Mode4 switching capability
   - Telemetry setup

2. **Before first flight**:
   - Test all control surfaces (correct direction)
   - Verify arming sequence
   - Test throttle cutoff
   - Check failsafe behavior
   - Range test

3. **Customization**:
   - Adjust rates/expo to preference
   - Modify switch assignments as needed
   - Add additional channels for accessories
   - Fine-tune mixes for your specific aircraft

4. **File locations**:
   - Save .yml files to: `MODELS/` folder on SD card
   - Companion app can import/export these configurations
