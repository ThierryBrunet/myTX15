# Aircraft Model Templates

## Quadcopter Templates

### 01. Angel30 3-inch Carbon Fiber Frame

#### 01.01 Model Specifications
- **Frame**: Angel30 3-inch carbon fiber
- **Flight Controller**: DarwinFPV F415 AIO with integrated ELRS
- **ESC**: 4-in-1 BLHeli_S ESC
- **Motors**: 1104 5000KV brushless motors
- **Propellers**: 3-inch tri-blade
- **Battery**: 2S LiPo (300-450mAh)
- **Weight**: 45-65g (ready to fly)

#### 01.02 EdgeTX Model Configuration
```yaml
# Angel30-Quad.yml
name: Angel30-Quad
model:
  type: Multirotor
  subtype: QuadX
  template: Quadcopter

module:
  type: CRSF
  rfProtocol: ExpressLRS
  channels: 8

controls:
  aileron: CH1
  elevator: CH2
  throttle: CH3
  rudder: CH4

flightModes:
  - name: Indoors
    switch: SA-down
    curves:
      throttle: "0,25,50,75,85"
      pitch: "0,20,40,60,70"
      roll: "0,20,40,60,70"
      yaw: "0,25,50,75,85"

  - name: Outdoors
    switch: SA-mid
    curves:
      throttle: "0,35,65,85,95"
      pitch: "0,30,60,80,90"
      roll: "0,30,60,80,90"
      yaw: "0,35,65,85,95"

  - name: Normal
    switch: SA-up
    curves:
      throttle: "0,50,75,90,100"
      pitch: "0,50,75,90,100"
      roll: "0,50,75,90,100"
      yaw: "0,50,75,90,100"

arming:
  preArm:
    throttle: min
    switch: SB-up
  arm:
    switch: SC-up
  throttleCutoff:
    switch: SF-up
    channel: CH3
    value: -100
```

#### 01.03 Betaflight Passthrough Settings
```
# Normal Mode Configuration
rc_rate: 1.0
super_rate: 0.7
expo: 0.3

# Indoors Mode Configuration
rc_rate: 0.7
super_rate: 0.5
expo: 0.4

# Outdoors Mode Configuration
rc_rate: 0.85
super_rate: 0.6
expo: 0.35
```

## Fixed-Wing Templates

### 02. Flying Bear Fx707s Aircraft

#### 02.01 Model Specifications
- **Wingspan**: 707mm
- **Weight**: 180-220g (ready to fly)
- **Motor**: 2204 2300KV brushless
- **ESC**: 20A with BEC
- **Servo**: 9g digital servos (2x elevator, 1x rudder)
- **Battery**: 2S-3S LiPo (450-850mAh)
- **Receiver**: Cyclone ELRS (CRSF) or HPXGRC
- **Gyro**: Reflex V3 Flight Controller

#### 02.02 EdgeTX Model Configuration
```yaml
# Fx707s-FixedWing.yml
name: Fx707s-FixedWing
model:
  type: Airplane
  subtype: Flying-wing
  template: Flying-wing

module:
  type: CRSF
  rfProtocol: ExpressLRS
  channels: 8

controls:
  aileron: CH1
  elevator: CH2
  throttle: CH3
  rudder: CH4

flightModes:
  - name: Beginner
    switch: SA-down
    gyro:
      gain: 80
      mode: Rate
    curves:
      elevator: "-100,-50,0,50,100"
      aileron: "-70,-35,0,35,70"

  - name: Advanced
    switch: SA-mid
    gyro:
      gain: 50
      mode: Rate
    curves:
      elevator: "-100,-60,0,60,100"
      aileron: "-85,-45,0,45,85"

  - name: Manual
    switch: SA-up
    gyro:
      gain: 20
      mode: Manual
    curves:
      elevator: "-100,-70,0,70,100"
      aileron: "-100,-60,0,60,100"

arming:
  preArm:
    throttle: min
    switch: SB-up
  arm:
    switch: SC-up
  throttleCutoff:
    switch: SF-up
    channel: CH3
    value: -100
```

### 03. 50CM Big Foam Plane

#### 03.01 Model Specifications
- **Wingspan**: 500mm
- **Weight**: 120-160g (ready to fly)
- **Motor**: 1804 2300KV brushless
- **ESC**: 15A with BEC
- **Servo**: 9g digital servos (2x elevator, 1x rudder)
- **Battery**: 2S LiPo (300-450mAh)
- **Receiver**: Cyclone ELRS (PWM or CRSF)
- **Gyro**: ICM-20948 Module

#### 03.02 EdgeTX Model Configuration
```yaml
# BigFoam-50cm.yml
name: BigFoam-50cm
model:
  type: Airplane
  subtype: Airplane
  template: Trainer

module:
  type: CRSF
  rfProtocol: ExpressLRS
  channels: 8

controls:
  aileron: CH1
  elevator: CH2
  throttle: CH3
  rudder: CH4

flightModes:
  - name: Beginner
    switch: SA-down
    gyro:
      gain: 85
      mode: Stabilize
    curves:
      elevator: "-80,-40,0,40,80"
      aileron: "-60,-30,0,30,60"

  - name: Advanced
    switch: SA-mid
    gyro:
      gain: 55
      mode: Rate
    curves:
      elevator: "-90,-50,0,50,90"
      aileron: "-75,-40,0,40,75"

  - name: Manual
    switch: SA-up
    gyro:
      gain: 25
      mode: Manual
    curves:
      elevator: "-100,-65,0,65,100"
      aileron: "-90,-50,0,50,90"

arming:
  preArm:
    throttle: min
    switch: SB-up
  arm:
    switch: SC-up
  throttleCutoff:
    switch: SF-up
    channel: CH3
    value: -100
```

### 04. EDGE540 EPP F3P

#### 04.01 Model Specifications
- **Wingspan**: 540mm
- **Weight**: 140-180g (ready to fly)
- **Motor**: 2203 2600KV brushless
- **ESC**: 20A with BEC
- **Servo**: 9g metal gear servos (2x elevator, 1x rudder)
- **Battery**: 2S-3S LiPo (450-650mAh)
- **Receiver**: Cyclone ELRS (CRSF)
- **Gyro**: Reflex V3 Flight Controller

#### 04.02 EdgeTX Model Configuration
```yaml
# EDGE540-EPP.yml
name: EDGE540-EPP
model:
  type: Airplane
  subtype: Airplane
  template: Acro

module:
  type: CRSF
  rfProtocol: ExpressLRS
  channels: 8

controls:
  aileron: CH1
  elevator: CH2
  throttle: CH3
  rudder: CH4

flightModes:
  - name: Beginner
    switch: SA-down
    gyro:
      gain: 70
      mode: Stabilize
    curves:
      elevator: "-100,-50,0,50,100"
      aileron: "-80,-40,0,40,80"

  - name: Advanced
    switch: SA-mid
    gyro:
      gain: 40
      mode: Rate
    curves:
      elevator: "-100,-60,0,60,100"
      aileron: "-95,-50,0,50,95"

  - name: Manual
    switch: SA-up
    gyro:
      gain: 15
      mode: Manual
    curves:
      elevator: "-100,-70,0,70,100"
      aileron: "-100,-60,0,60,100"

arming:
  preArm:
    throttle: min
    switch: SB-up
  arm:
    switch: SC-up
  throttleCutoff:
    switch: SF-up
    channel: CH3
    value: -100

mixes:
  - output: CH1
    input: Aileron
    weight: 100
    curve: "Diff:15"

  - output: CH2
    input: Elevator
    weight: 100

  - output: CH3
    input: Throttle
    weight: 100

  - output: CH4
    input: Rudder
    weight: 100
```

## Template Application Guidelines

### 05.01 Customization Process
1. **Start with template**: Copy appropriate template configuration
2. **Hardware matching**: Adjust for specific receiver and gyro
3. **Flight testing**: Begin with Beginner/Indoors mode
4. **Progressive tuning**: Gradually increase authority as confidence grows
5. **Documentation**: Record all changes and flight results

### 05.02 Safety Considerations
- **Always start conservative**: Beginner modes first
- **Verify arming**: Test two-step sequence thoroughly
- **Throttle cutoff**: Confirm emergency shutdown works
- **Range check**: Verify signal integrity before flight

### 05.03 Performance Optimization
- **Rate tuning**: Adjust based on pilot skill level
- **Curve shaping**: Fine-tune for specific aircraft characteristics
- **Gyro settings**: Balance stability vs. responsiveness
- **Failsafe setup**: Configure appropriate safety positions