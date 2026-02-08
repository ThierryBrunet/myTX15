# Hardware Specifications

## WBS: 01.00.00 - Hardware Inventory

### 01.01.00 - Transmitter

#### RadioMaster TX15 Mark II

**Specifications**:
- **Radio System**: Multi-protocol (ELRS, CRSF, GHST, etc.)
- **Internal RF**: ExpressLRS 2.4GHz (optional module)
- **External Module Bay**: JR-style bay for external modules
- **Processor**: STM32F4
- **Display**: 3.5" color LCD (480x320)
- **Gimbals**: Hall sensor gimbals (CNC machined)
- **Battery**: 2x 18650 Li-ion (included) or external power
- **Firmware**: EdgeTX (OpenTX fork)
- **Storage**: MicroSD card (provided)
- **Audio**: Speaker + vibration motor
- **Connectivity**: USB-C, Trainer port, S.Port

**Switch Layout**:
```
Top Left (Front):
  SA - 3-position (↓ mid ↑)
  SB - 3-position (↓ mid ↑)
  
Top Right (Front):
  SC - 3-position (↓ mid ↑)
  SD - 3-position (↓ mid ↑)
  
Shoulders:
  SE - 2-position momentary
  SF - 2-position toggle
  
Front Panel:
  SG - 2-position toggle
  SH - 2-position toggle
```

**Potentiometers/Sliders**:
- S1 - Left side slider
- S2 - Right side slider
- LS - Left shoulder dial
- RS - Right shoulder dial

**Default Stick Mode**: Mode 2 (Throttle left, Aileron/Elevator right)

**SD Card Path**: D:\ (when connected via USB)

---

### 01.02.00 - Receivers

#### 01.02.01 - AliExpress ELRS 2.4GHz PWM 7CH (Cyclone)

**Product Link**: https://www.aliexpress.com/item/1005007033545569.html

**Specifications**:
- **Frequency**: 2.4GHz ISM band
- **Protocol**: ExpressLRS
- **Output Modes**: 
  - PWM (7 channels, 50Hz)
  - CRSF (serial, 16 channels, full telemetry)
- **MCU**: ESP8285 or similar
- **Antenna**: Onboard ceramic + external connector
- **Power Input**: 5V (50-500mA)
- **Dimensions**: ~20x12x5mm
- **Weight**: ~2g
- **Mounting**: 2x M2 holes (16mm spacing)

**Configuration Files**:
- `7CH.json` - PWM 7-channel mode
- `CRSF.json` - CRSF serial mode

**Pin Diagram** (PWM Mode):
```
[VCC] [GND] [CH1] [CH2] [CH3] [CH4] [CH5] [CH6] [CH7]
  5V   GND  Ail   Ele   Thr   Rud  Aux1  Aux2  Aux3
```

**LED Indicators**:
- Solid: Bound and receiving
- Slow blink: Searching for TX
- Fast blink: Bind mode
- Off: No power

**Use Cases**:
- Fixed wing aircraft with PWM servos
- Planes requiring traditional servo outputs
- When CRSF/FC not needed

#### 01.02.02 - HPXGRC 2.4G ExpressLRS Receiver

**Product Link**: https://www.aliexpress.com/item/1005009645506956.html

**Specifications**:
- **Frequency**: 2.4GHz
- **Protocol**: ExpressLRS (CRSF only)
- **Output**: Serial CRSF (420000 baud)
- **Channels**: 16 (via CRSF)
- **Telemetry**: Full bidirectional
- **MCU**: ESP-based
- **Antennas**: Dual diversity (T-antenna + PCB)
- **Power Input**: 5V (40-300mA)
- **Dimensions**: ~15x10x3mm
- **Weight**: ~1.5g
- **Mounting**: 2x M2 holes (12mm spacing)

**Pin Diagram**:
```
[VCC] [GND] [TX] [RX]
  5V   GND  To FC RX  To FC TX
```

**Features**:
- Diversity antenna switching
- Full telemetry support
- Low latency
- Small form factor

**Use Cases**:
- General quadcopter builds
- Any CRSF-compatible flight controller
- Space-constrained builds
- When telemetry is required

#### 01.02.03 - DarwinFPV F415 AIO Flight Controller

**Product Link**: https://www.aliexpress.com/item/1005009990173646.html

**Specifications**:
- **Flight Controller**: 
  - MCU: STM32F405
  - Gyro: ICM-42688P (SPI)
  - Firmware: Betaflight 4.3+
  - Barometer: DPS310 (optional)
  - OSD: AT7456E
  
- **ESC**:
  - Type: 4-in-1 BLHeli_32
  - Current: 35A continuous, 40A burst (per motor)
  - Input: 2-6S LiPo
  - Protocols: DShot300/600, Multishot, Oneshot
  
- **Integrated ELRS Receiver**:
  - Frequency: 2.4GHz
  - Protocol: ExpressLRS
  - Output: CRSF to FC (internal connection)
  - Telemetry: Full support
  - Antenna: IPEX connector (external required)

- **Physical**:
  - Mounting: 20x20mm / 30.5x30.5mm
  - Dimensions: 36x36mm
  - Weight: ~10g
  - Stack height: ~7mm

**Pin Diagram**:
```
Motors:      M1  M2  M3  M4
Power:       BAT+ BAT- 5V GND
Video:       VTX+ VTX- CAM+ CAM- GND
UARTs:       TX1 RX1 TX2 RX2 TX3 RX3
             (UART1 used by ELRS internally)
Other:       LED Buzzer SDA SCL
```

**UART Allocation** (typical Betaflight config):
- UART1: ELRS receiver (CRSF) - Internal
- UART2: Available for GPS, telemetry, etc.
- UART3: Available for SmartAudio, ESC telemetry

**Use Cases**:
- 3-5 inch quadcopters
- All-in-one builds (saves space/weight)
- When integrated ELRS is desired
- Racing and freestyle drones

---

### 01.03.00 - Gyroscopes / Stabilization

#### 01.03.01 - Reflex V3 Flight Controller Gyro Stabilizer

**Product Link**: https://www.aliexpress.com/item/1005010233202104.html

**Specifications**:
- **Type**: 6-axis gyro stabilizer
- **Gyro**: MPU-6050 or similar
- **Modes**: 
  - Beginner (full stabilization + auto-level)
  - Advanced (partial stabilization)
  - Manual (gyro off or minimal)
- **Control**: Via PWM channel (typically CH5)
- **Channels**: 3-axis (Aileron, Elevator, Rudder)
- **Power Input**: 5-8.4V (from receiver or BEC)
- **Output**: PWM to servos (50Hz standard)
- **Dimensions**: ~40x20mm
- **Weight**: ~8g

**Channel Mapping**:
```
Inputs (from receiver):
  CH1 - Aileron
  CH2 - Elevator  
  CH3 - Throttle (passthrough, no gyro)
  CH4 - Rudder
  CH5 - Mode select (1100μs=Beginner, 1500μs=Advanced, 1900μs=Manual)
  
Outputs (to servos):
  CH1 - Aileron (gyro-stabilized)
  CH2 - Elevator (gyro-stabilized)
  CH3 - Throttle (direct passthrough)
  CH4 - Rudder (gyro-stabilized)
```

**Mode Selection** (Channel 5 PWM values):
- **< 1300μs**: Beginner mode
  - Full 3-axis stabilization
  - Auto-level enabled
  - Gentle control response
  - Best for learning
  
- **1300-1700μs**: Advanced mode
  - Partial stabilization
  - Rate mode (no auto-level)
  - More responsive
  
- **> 1700μs**: Manual mode
  - Minimal or no gyro assistance
  - Direct control
  - For experienced pilots

**Firmware Updates**:
- Website: www.fmsmodel.com/page/reflex
- Update via USB (micro-USB on board)
- Required for bug fixes and new features

**Use Cases**:
- Fixed wing aircraft (especially foamies)
- Trainers and beginner planes
- 3D aerobatic planes (can disable gyro)
- Adding stabilization to existing planes

**Setup Procedure**:
1. Connect power (5-8.4V)
2. Connect RX channels 1-5 to Reflex inputs
3. Connect Reflex outputs to servos (CH1-4)
4. Set neutral on radio with gyro in manual mode
5. Calibrate gyro (place level, power cycle)
6. Test each mode on ground
7. Trim in manual mode first
8. Test flight in beginner mode

#### 01.03.02 - ICM-20948 9-Axis MEMS Module

**Product Link**: https://www.aliexpress.com/item/1005010143994669.html

**Specifications**:
- **Sensors**:
  - Gyroscope: 3-axis (±250, ±500, ±1000, ±2000 dps)
  - Accelerometer: 3-axis (±2, ±4, ±8, ±16g)
  - Magnetometer: 3-axis (AK09916)
- **Interface**: I2C or SPI
- **Power**: 3.3V (VCC) or 5V (VIN with regulator)
- **Dimensions**: ~25x15mm
- **Weight**: ~1g

**Pin Diagram**:
```
VCC  - 3.3V or 5V power
GND  - Ground
SCL  - I2C clock
SDA  - I2C data
INT  - Interrupt (optional)
AD0  - I2C address select
```

**I2C Addresses**:
- AD0 LOW: 0x68
- AD0 HIGH: 0x69

**Use Cases**:
- Custom flight controller builds
- Fixed wing orientation sensing
- Heading hold systems
- Advanced stabilization projects
- Better suited for fixed wings (less vibration)

**Advantages over 6-axis**:
- Magnetometer for heading reference
- Better for GPS-assisted flight
- Compass functionality
- More stable in windy conditions

#### 01.03.03 - ICM-45686 6-Axis MEMS Module

**Product Link**: https://www.aliexpress.com/item/1005010560842695.html

**Specifications**:
- **Sensors**:
  - Gyroscope: 3-axis (high rate capability)
  - Accelerometer: 3-axis (high G capability)
- **Interface**: SPI (high speed)
- **Power**: 3.3V
- **Sample Rate**: Up to 32kHz (gyro)
- **Dimensions**: ~20x10mm
- **Weight**: ~0.5g

**Pin Diagram**:
```
VCC  - 3.3V power
GND  - Ground
SCK  - SPI clock
MISO - SPI data in
MOSI - SPI data out
CS   - Chip select
INT  - Interrupt
```

**Use Cases**:
- Quadcopter flight controllers
- High vibration environments
- Racing drones (fast response needed)
- Freestyle drones
- Better vibration tolerance than ICM-20948

**Advantages for quads**:
- Higher sample rate (better for PID loops)
- Better vibration filtering
- Lower latency
- Optimized for fast movements

---

### 01.04.00 - Aircraft

#### 01.04.01 - Quadcopters

##### Angel30 3" Carbon Fiber Frame

**Product Link**: https://www.aliexpress.com/item/1005009618459237.html

**Specifications**:
- **Size**: 3 inch (prop size)
- **Material**: Carbon fiber (3mm arms, 2mm plates)
- **Wheelbase**: ~130mm
- **Weight**: ~30g (frame only)
- **Motor Mounting**: 12x12mm or 16x16mm pattern
- **FC Mounting**: 20x20mm or 30.5x30.5mm
- **Camera**: Micro or nano sized (supports both)

**Recommended Components**:
- **Motors**: 1408 or 1507 size (3000-4000kV)
- **Props**: 3" (3025, 3028, 3035)
- **FC/ESC**: DarwinFPV F415 AIO (perfect fit)
- **Camera**: Foxeer Razer Micro or similar
- **VTX**: 25-200mW (400mW max for racing)
- **Battery**: 3S or 4S 650-850mAh
- **Receiver**: DarwinFPV built-in ELRS

**Build Weight** (typical):
- Frame: 30g
- Motors (4x): 36g (9g each)
- FC/ESC/RX: 10g (DarwinFPV AIO)
- Camera: 5g
- VTX: 3g
- Battery: 70g (4S 650mAh)
- Props: 8g
- **Total**: ~160g ready to fly

**Flight Characteristics**:
- **Indoor**: Excellent (small, agile)
- **Outdoor**: Good in light wind
- **Speed**: Moderate (not as fast as 5")
- **Flight Time**: 3-5 minutes (aggressive flying)
- **Skill Level**: Intermediate

**Configuration**:
- Use DarwinFPV F415 receiver (built-in)
- Betaflight firmware
- 3 flight modes: Indoor/Outdoor/Normal
- 2-step arming for safety

#### 01.04.02 - Fixed Wings

##### Flying Bear FX707S

**Product Link**: https://www.aliexpress.com/item/1005007456726266.html

**Specifications**:
- **Wingspan**: ~70cm
- **Length**: ~70cm
- **Material**: EPO foam
- **Weight**: ~150g (airframe)
- **Flight Type**: Park flyer / trainer
- **Power**: Electric (brushed → brushless conversion)

**Conversion Specifications**:
- **Motor**: 1806 or 2204 (2000-2800kV)
- **ESC**: 12-20A (BLHELI_S or similar)
- **Prop**: 6x4 or 7x5
- **Battery**: 3S 800-1200mAh
- **Servos**: 3x 9g servos (aileron, elevator, rudder)
- **Receiver**: Cyclone PWM 7CH (ideal)
- **Gyro**: Reflex V3 (recommended for stability)

**Channel Mapping**:
```
CH1 - Aileron
CH2 - Elevator
CH3 - Throttle
CH4 - Rudder
CH5 - Reflex mode (Beginner/Advanced/Manual)
CH6 - Throttle cut
CH7 - Arm switch
```

**Flight Characteristics**:
- **Beginner Friendly**: Yes (with Reflex gyro)
- **Speed**: Slow to moderate
- **Wind Tolerance**: Light wind only
- **Flight Time**: 8-12 minutes
- **Skill Level**: Beginner to intermediate

##### 50CM Big Foam Plane

**Product Link**: https://www.aliexpress.com/item/1005006154281634.html

**Specifications**:
- **Wingspan**: ~50cm
- **Length**: Variable (depends on model)
- **Material**: EPP/EPO foam
- **Weight**: ~80-120g (airframe)
- **Flight Type**: Indoor/light outdoor

**Conversion Specifications**:
- **Motor**: 1306 or 1408 (3000-4000kV)
- **ESC**: 10-15A
- **Prop**: 5x4 or 6x3
- **Battery**: 2S 450-650mAh or 3S 300-450mAh
- **Servos**: 2-3x 5g micro servos
- **Receiver**: Cyclone PWM (compact size)
- **Gyro**: Reflex V3 or ICM-20948 based system

**Channel Mapping**:
```
CH1 - Aileron (or rudder if 2-channel)
CH2 - Elevator
CH3 - Throttle
CH4 - Rudder (if 3+ channel)
CH5 - Gyro mode
CH6 - Throttle cut (optional)
```

**Flight Characteristics**:
- **Indoor**: Excellent (light weight)
- **Outdoor**: Light wind only
- **Speed**: Slow
- **Flight Time**: 10-15 minutes
- **Skill Level**: Beginner

##### EDGE540 EPP F3P

**Product Link**: https://item.taobao.com/item.htm?id=18053051397

**Specifications**:
- **Wingspan**: Variable (typically 800-1000mm)
- **Material**: EPP foam (very durable)
- **Type**: F3P indoor aerobatic
- **Weight**: ~120-180g (airframe)
- **Flight Type**: 3D aerobatics, precision

**Conversion Specifications**:
- **Motor**: 1806-2204 (2200-2800kV)
- **ESC**: 15-25A (need reverse thrust capability)
- **Prop**: 7x6 to 8x6 (large for 3D)
- **Battery**: 3S 850-1300mAh
- **Servos**: 4x 9g digital servos (aileron x2, elevator, rudder)
- **Receiver**: Cyclone PWM or HPXGRC
- **Gyro**: Optional (most F3P pilots prefer manual)

**Channel Mapping**:
```
CH1 - Aileron (right)
CH2 - Elevator
CH3 - Throttle
CH4 - Rudder
CH5 - Aileron (left) - or mixed with CH1
CH6 - Flight mode / Expo switch
CH7 - Throttle cut / Motor reverse
```

**Flight Characteristics**:
- **Indoor**: Designed for indoor
- **Outdoor**: Light wind, parking lot flying
- **Speed**: Variable (slow hover to fast passes)
- **Maneuvers**: Harriers, hovers, knife edge, torque rolls
- **Flight Time**: 8-15 minutes
- **Skill Level**: Advanced to expert

**Special Notes**:
- Requires high control authority
- Dual aileron servos recommended
- Large control surfaces for 3D
- May need motor reverse for "prop hanging"
- Precision trimming essential

---

## Summary Table

| Component | Type | Use Case | Connectivity |
|-----------|------|----------|--------------|
| TX15 | Transmitter | All models | ELRS 2.4GHz |
| Cyclone | RX (PWM/CRSF) | Fixed wings | 7CH PWM or serial |
| HPXGRC | RX (CRSF) | General purpose | Serial CRSF |
| DarwinFPV F415 | AIO FC+RX | Quads 3-5" | Integrated ELRS |
| Reflex V3 | Gyro stabilizer | Fixed wings | PWM passthrough |
| ICM-20948 | 9-axis IMU | Custom FC (planes) | I2C/SPI |
| ICM-45686 | 6-axis IMU | Custom FC (quads) | SPI |
| Angel30 | 3" quad frame | Freestyle/indoor | - |
| FX707S | Foamy plane | Beginner trainer | - |
| 50CM Foam | Small plane | Indoor/light outdoor | - |
| EDGE540 | F3P plane | 3D aerobatics | - |

---

## Power Requirements Summary

### Transmitter
- TX15: 2x 18650 batteries (7.4V, ~3000mAh each)
- Runtime: 8-12 hours continuous

### Receivers
- All ELRS receivers: 5V @ 40-500mA (from BEC or FC)

### Gyros
- Reflex V3: 5-8.4V @ ~100mA
- ICM modules: 3.3-5V @ ~10mA

### Aircraft (typical)
- 3" Quad (Angel30): 3S-4S 650-850mAh (11.1-14.8V)
- FX707S: 3S 800-1200mAh
- 50CM Foam: 2S-3S 450-650mAh
- EDGE540: 3S 850-1300mAh

---

## Maintenance Schedule

### Weekly (active use)
- Check TX battery voltage
- Inspect receiver antennas
- Clean aircraft foam (remove grass, dirt)
- Check propeller condition (quads)

### Monthly
- Update ELRS firmware (check for new stable releases)
- Update EdgeTX firmware
- Calibrate TX gimbals
- Clean gimbal potentiometers (if drifting)
- Charge/cycle 18650 batteries

### Quarterly
- Update Betaflight (quads)
- Re-bind all receivers (fresh binding)
- Check servo function (planes)
- Inspect control surfaces (planes)
- Check motor bearings (quads)

### Annually
- Replace TX 18650 batteries (if degraded)
- Replace aircraft batteries (check internal resistance)
- Re-solder any questionable connections
- Full system calibration
