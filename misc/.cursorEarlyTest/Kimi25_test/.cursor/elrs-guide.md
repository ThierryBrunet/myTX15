# ExpressLRS Configuration Guide for Cursor

## Overview

ExpressLRS (ELRS) is the long-range, low-latency RC link protocol. This guide covers receiver configuration, binding, and troubleshooting for the three receiver types in your inventory.

## WBS: 01.02.00 - ExpressLRS Setup

### 01.02.01 - Firmware Versions

**Target Versions**:
- ExpressLRS: Latest stable (non-RC) release
- ExpressLRS Configurator: Latest stable release

**Check for updates**:
```bash
# From ExpressLRS Configurator
# https://github.com/ExpressLRS/ExpressLRS-Configurator/releases
```

### 01.02.02 - Receiver Hardware Specifications

#### Receiver 1: AliExpress ELRS 2.4GHz PWM 7CH (Cyclone)

**Specifications**:
- Frequency: 2.4GHz
- Output modes: PWM (7 channels) OR CRSF (serial)
- Antenna: Ceramic or wire dipole
- Power: 5V from BEC
- Size: ~20x12mm

**Configuration Files**:
```json
// 7CH.json - PWM Mode Configuration
{
  "product_name": "Cyclone 2.4GHz",
  "lua_name": "Cyclone PWM",
  "layout_file": "Cyclone_PWM.json",
  "features": [
    "PWM Output"
  ],
  "prior_target_name": null,
  "firmware_upload_method": "betaflight"
}

// CRSF.json - CRSF Mode Configuration  
{
  "product_name": "Cyclone 2.4GHz",
  "lua_name": "Cyclone CRSF",
  "layout_file": "Cyclone_CRSF.json",
  "features": [
    "CRSF Serial",
    "Full Telemetry"
  ],
  "prior_target_name": null,
  "firmware_upload_method": "betaflight"
}
```

**When to use**:
- PWM mode: Fixed wings with traditional servos
- CRSF mode: When connecting to flight controller (Betaflight, iNav)

**Flashing procedure**:
1. Connect receiver to FC via USB
2. Open ExpressLRS Configurator
3. Select device: "AliExpress_ELRS_2400_RX_PWM" or "AliExpress_ELRS_2400_RX_CRSF"
4. Select version: Latest stable
5. Flash via Betaflight passthrough

#### Receiver 2: HPXGRC 2.4G ExpressLRS

**Specifications**:
- Frequency: 2.4GHz
- Output mode: CRSF only
- Telemetry: Full support
- Power: 5V from FC
- Size: ~15x10mm

**Configuration**:
```json
{
  "product_name": "HPXGRC 2.4G",
  "lua_name": "HPXGRC",
  "layout_file": "HPXGRC.json",
  "features": [
    "CRSF Serial",
    "Full Telemetry",
    "Diversity Antenna"
  ],
  "firmware_upload_method": "betaflight"
}
```

**When to use**:
- General purpose quadcopters
- Any setup requiring CRSF
- When telemetry is needed

#### Receiver 3: DarwinFPV F415 AIO

**Specifications**:
- Integrated: Flight Controller + 4in1 ESC + ELRS receiver
- MCU: STM32 F4
- ESC: 4x BLHeli_32 (35A burst)
- Receiver: Built-in ELRS 2.4GHz
- UART: Multiple for peripherals
- I2C: For external sensors

**Configuration**:
```json
{
  "product_name": "DarwinFPV F415 AIO",
  "lua_name": "Darwin F415",
  "layout_file": "DarwinFPV_F415.json",
  "features": [
    "Integrated FC",
    "4in1 ESC",
    "ELRS 2.4G",
    "CRSF Native",
    "Full Telemetry"
  ],
  "firmware_upload_method": "DFU"
}
```

**When to use**:
- Compact quadcopter builds (3-5 inch)
- All-in-one solution
- Space-constrained builds

**Special notes**:
- Flash Betaflight to FC separately from ELRS receiver
- ELRS receiver flashed via Betaflight passthrough
- Configure UART for CRSF (usually UART1 or UART2)

### 01.02.03 - Binding Procedure

#### Method 1: Binding Phrase (Recommended)

**On TX15 (EdgeTX)**:
1. Navigate to Model Settings
2. Go to External Module
3. Select ExpressLRS
4. Set Binding Phrase (e.g., "my_bind_phrase_2024")
5. Save settings

**On Receiver**:
1. Flash receiver firmware with same binding phrase
2. In ExpressLRS Configurator:
   ```
   Options → Binding Phrase → "my_bind_phrase_2024"
   ```
3. Flash firmware
4. Receiver automatically binds on power-up

**Advantages**:
- No button pressing needed
- Consistent across multiple receivers
- Easy to rebind

#### Method 2: Traditional Binding

**Steps**:
1. Power on TX15
2. Hold receiver bind button while powering up
3. LED blinks rapidly (bind mode)
4. On TX15: Model Settings → External Module → [Bind]
5. Wait for solid LED on receiver
6. Power cycle receiver to confirm

### 01.02.04 - Packet Rate Configuration

**Available rates** (2.4GHz):
- 50Hz: Maximum range (~30km), higher latency (20ms)
- 150Hz: Long range (~10km), low latency (6.7ms)
- 250Hz: Medium range (~5km), very low latency (4ms)
- 500Hz: Short range (~2km), ultra-low latency (2ms)

**Recommendations**:
```yaml
# Fixed wings (range priority)
packet_rate: 150Hz or 250Hz
telemetry_ratio: 1:4

# Racing quads (latency priority)
packet_rate: 500Hz
telemetry_ratio: 1:16

# Freestyle quads (balanced)
packet_rate: 250Hz
telemetry_ratio: 1:8

# Long range
packet_rate: 50Hz or 100Hz
telemetry_ratio: 1:2
```

**Setting packet rate on TX15**:
1. Model Settings → External Module
2. ExpressLRS Settings (long press SYS)
3. Packet Rate → Select desired rate
4. Send to receiver (automatically)

### 01.02.05 - Telemetry Configuration

**Available telemetry**:
- RSSI (signal strength)
- LQ (link quality percentage)
- SNR (signal-to-noise ratio)
- TX Power (current transmit power)
- RX Battery voltage
- Flight mode (from FC)
- GPS data (if connected)

**EdgeTX telemetry setup**:
```yaml
# Enable telemetry discovery
telemetry:
  - auto_discover: true
    protocol: "CRSF"
    
# Standard sensors (auto-discovered)
sensors:
  - name: "RSSI"
    id: 0xF101
  - name: "RQly"  # Link quality
    id: 0xF102
  - name: "RSNR"
    id: 0xF103
  - name: "RxBt"  # Battery
    id: 0xF104

# Telemetry alarms
specialFunctions:
  # Low RSSI warning (< -100dBm)
  - switch: "L30"
    function: PLAY_VALUE
    param: "RSSI"
    
  # Low link quality (< 50%)
  - switch: "L31"
    function: PLAY_SOUND
    param: "lowlink.wav"
```

**Logical switches for alarms**:
```yaml
logicalSwitches:
  # L30: RSSI too low
  - function: "a<x"
    v1: RSSI
    v2: -100
    
  # L31: Link quality too low
  - function: "a<x"
    v1: RQly
    v2: 50
```

### 01.02.06 - Failsafe Configuration

**WBS: 01.02.06 - Failsafe Settings**

#### For Quadcopters (DarwinFPV F415)

**Betaflight failsafe**:
```
# In Betaflight CLI
set failsafe_procedure = DROP
set failsafe_delay = 15        # 1.5 seconds
set failsafe_off_delay = 50    # 5 seconds
set failsafe_throttle = 1000   # Min throttle
save
```

**EdgeTX failsafe** (backup):
```yaml
# Set failsafe mode in External Module
failsafe:
  mode: "Custom"
  
  # Failsafe channel positions
  channels:
    CH1: 0      # Aileron center
    CH2: 0      # Elevator center
    CH3: -100   # Throttle minimum
    CH4: 0      # Rudder center
    CH5: -100   # Disarm
    CH6: 0      # Flight mode (angle mode)
```

#### For Fixed Wings (Cyclone PWM)

**PWM receiver failsafe**:
1. Set sticks to desired failsafe position:
   - Throttle: Low (but not zero for glide)
   - Ailerons: Center
   - Elevator: Slight up (maintain altitude)
   - Rudder: Center
2. Enter receiver bind mode
3. On TX15: Model Settings → Set Failsafe
4. Receiver saves current stick positions
5. Exit bind mode

**Recommended positions**:
```yaml
failsafe_positions:
  throttle: 25%      # Gentle glide
  aileron: center
  elevator: +5%      # Slight up trim
  rudder: center
  reflex_mode: beginner  # Full stabilization
```

### 01.02.07 - Power Output Settings

**Available TX power** (2.4GHz):
- 10mW: Indoor/close range
- 25mW: Park flying
- 50mW: General flying
- 100mW: Long range
- 250mW: Maximum range
- 500mW: Extended range (with cooling)
- 1000mW: Extreme range (TX15 maximum, requires fan)

**Dynamic power**:
- Enable "Dynamic Power" in ELRS settings
- Automatically adjusts based on RSSI
- Saves battery life
- Reduces interference

**Setting on TX15**:
```yaml
# Model Settings → External Module → ExpressLRS
power:
  mode: "Dynamic"
  max_power: 100  # mW
  
# OR fixed power
power:
  mode: "Fixed"
  level: 50  # mW
```

### 01.02.08 - Channel Mapping

**CRSF channel order** (Betaflight/iNav):
```
CH1: Roll (Aileron)
CH2: Pitch (Elevator)  
CH3: Throttle
CH4: Yaw (Rudder)
CH5: AUX1 (Arm)
CH6: AUX2 (Flight mode)
CH7: AUX3
CH8: AUX4
...
CH16: AUX12 (CRSF supports 16 channels)
```

**PWM channel order** (Cyclone 7CH):
```
CH1: Aileron
CH2: Elevator
CH3: Throttle
CH4: Rudder
CH5: Aux1
CH6: Aux2
CH7: Aux3
```

**Mapping in EdgeTX**:
```yaml
# Standard AETR mapping
mixes:
  - dest: CH1
    source: Ail
  - dest: CH2
    source: Ele
  - dest: CH3
    source: Thr
  - dest: CH4
    source: Rud
```

### 01.02.09 - Flashing Firmware

**Using ExpressLRS Configurator**:

1. **Install Configurator**
   ```bash
   # Download from GitHub
   https://github.com/ExpressLRS/ExpressLRS-Configurator/releases
   
   # Install and run
   ```

2. **Select Target**
   ```
   Device Category: ExpressLRS 2.4GHz RX
   Device: [Your receiver model]
   Firmware Version: [Latest stable]
   ```

3. **Configure Options**
   ```yaml
   options:
     binding_phrase: "my_bind_phrase_2024"
     regulatory_domain: "ISM2G4"  # 2.4GHz
     performance:
       unlock_higher_power: false  # Keep disabled unless needed
   ```

4. **Flash Method**
   - **Via Betaflight**: Most common for FC-connected receivers
     1. Connect FC to PC via USB
     2. Configurator auto-detects passthrough
     3. Click "Build & Flash"
     
   - **Via WiFi**: For receivers with WiFi capability
     1. Power receiver in WiFi mode (hold bind button)
     2. Connect to "ExpressLRS RX" network
     3. Navigate to http://10.0.0.1
     4. Upload firmware via web interface
     
   - **Via UART**: Direct serial connection
     1. Connect UART adapter to RX/TX pins
     2. Select COM port in Configurator
     3. Click "Build & Flash"

### 01.02.10 - Receiver-Specific Configuration Files

#### Cyclone PWM Mode (7CH.json)
```json
{
  "product_name": "Cyclone PWM",
  "lua_name": "Cyclone 7CH",
  "layout_file": "Cyclone_PWM_layout.json",
  
  "features": [
    "PWM_OUTPUTS"
  ],
  
  "config": {
    "output_mode": "PWM",
    "channels": 7,
    "pwm_frequency": 50,
    "failsafe_mode": "HOLD_LAST"
  },
  
  "pinout": {
    "CH1": "PA0",
    "CH2": "PA1", 
    "CH3": "PA2",
    "CH4": "PA3",
    "CH5": "PA4",
    "CH6": "PA5",
    "CH7": "PA6"
  }
}
```

#### Cyclone CRSF Mode (CRSF.json)
```json
{
  "product_name": "Cyclone CRSF",
  "lua_name": "Cyclone Serial",
  "layout_file": "Cyclone_CRSF_layout.json",
  
  "features": [
    "CRSF_OUTPUT",
    "TELEMETRY"
  ],
  
  "config": {
    "output_mode": "CRSF",
    "serial_protocol": "CRSF",
    "baud_rate": 420000,
    "telemetry_ratio": "1:8"
  },
  
  "pinout": {
    "TX": "PA2",
    "RX": "PA3"
  }
}
```

## Troubleshooting

### Issue: No bind

**Checks**:
1. Verify binding phrase matches (TX and RX)
2. Ensure firmware versions compatible
3. Check receiver is in bind mode (LED blinking)
4. Verify TX module is set to ExpressLRS mode
5. Check antenna connected

**Solution**:
```bash
# Re-flash receiver with correct binding phrase
# Verify in Configurator: Options → Binding Phrase
```

### Issue: Poor range

**Checks**:
1. Verify packet rate (lower = better range)
2. Check TX power output
3. Inspect antennas (not damaged, proper orientation)
4. Check RSSI and LQ telemetry
5. Verify no interference (WiFi, other 2.4GHz)

**Solution**:
```yaml
# Increase TX power
power: 100  # or 250 mW

# Lower packet rate
packet_rate: 150Hz  # or 50Hz for max range

# Enable dynamic power
dynamic_power: true
```

### Issue: High latency

**Checks**:
1. Verify packet rate (higher = lower latency)
2. Check telemetry ratio (higher ratio = more bandwidth for RC)
3. Ensure no interference

**Solution**:
```yaml
# Increase packet rate
packet_rate: 500Hz

# Reduce telemetry
telemetry_ratio: 1:16
```

### Issue: Telemetry not working

**Checks**:
1. Verify CRSF mode (PWM doesn't support telemetry)
2. Check FC UART configuration (Betaflight)
3. Ensure serial RX protocol set to CRSF
4. Verify baud rate: 420000

**Betaflight configuration**:
```
# CLI commands
set serialrx_provider = CRSF
set serialrx_inverted = OFF
set serialrx_halfduplex = OFF
save
```

### Issue: Failsafe not triggering

**Checks**:
1. Verify failsafe configured in Betaflight (for CRSF)
2. Test by turning off TX
3. Check failsafe delay setting
4. For PWM: Ensure failsafe positions set

**Test procedure**:
```
1. Arm quad (on bench, props off!)
2. Verify motors running
3. Turn off TX
4. Verify motors stop within 1-2 seconds
5. Verify failsafe LED indicator
```

## Best Practices

1. **Always use binding phrase**
   - More secure than button binding
   - Easier to rebind multiple receivers
   - Consistent across all models

2. **Start with conservative settings**
   - 250Hz packet rate
   - 50-100mW power
   - Dynamic power enabled

3. **Test range before flying**
   - Walk away from model with TX
   - Monitor RSSI and LQ
   - Ensure >200m range minimum

4. **Use appropriate receiver for application**
   - PWM: Fixed wings with servos only
   - CRSF: Everything else (quads, FC-based)

5. **Keep firmware updated**
   - Check for updates monthly
   - Always use stable releases
   - Update TX and RX together

## Resources

- ExpressLRS Documentation: https://www.expresslrs.org/
- GitHub: https://github.com/ExpressLRS/ExpressLRS
- Discord: https://discord.gg/expresslrs
- Firmware Configurator: https://github.com/ExpressLRS/ExpressLRS-Configurator
