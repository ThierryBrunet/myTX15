# EdgeTX Configuration Overview

## 01. EdgeTX Architecture

### 01.01 Core Components
- **Radio Firmware**: EdgeTX running on RadioMaster TX15
- **Companion Software**: Windows/Linux application for configuration
- **Model Files**: YAML-based aircraft configurations
- **Lua Scripts**: Custom functionality and automation
- **Hardware Integration**: ExpressLRS protocol support

### 01.02 File Structure
```
EdgeTX/
├── models.yml          # Aircraft model definitions
├── radio.yml           # Transmitter configuration
├── hardware.ini        # Hardware-specific settings
├── MODELS/            # Model-specific files
│   ├── model01.yml
│   ├── model02.yml
│   └── ...
├── SCRIPTS/           # Lua scripts
│   ├── FUNCTIONS/
│   ├── MIXES/
│   └── TELEMETRY/
└── LOGS/              # Flight data logs
```

## 02. Model Configuration Framework

### 02.01 Model Types
- **Airplane**: Fixed-wing aircraft (normal, flying-wing, delta)
- **Multirotor**: Quadcopters, hexacopters, octocopters
- **Helicopter**: Single-rotor helicopters
- **Glider**: Sailplanes and gliders

### 02.02 Channel Assignment Standards
| Channel | Function | Notes |
|---------|----------|-------|
| 1 | Aileron | Roll control |
| 2 | Elevator | Pitch control |
| 3 | Throttle | Power control |
| 4 | Rudder | Yaw control |
| 5 | Flight Mode | Mode switching |
| 6 | Arming | Safety arming |
| 7+ | Auxiliary | Custom functions |

## 03. Input/Output System

### 03.01 Physical Inputs
- **Sticks**: Analog proportional controls
- **Switches**: Digital on/off controls
- **Knobs**: Analog rotary controls
- **Sliders**: Analog linear controls

### 03.02 Logical Switches
- **Conditions**: AND, OR, XOR operations
- **Comparisons**: Greater than, less than, equal
- **Timers**: Time-based conditions
- **Flight Modes**: Automatic switching logic

### 03.03 Mixers
- **Input Mixing**: Combine multiple inputs
- **Output Mixing**: Distribute to multiple servos
- **Curves**: Non-linear response shaping
- **Delays**: Transition smoothing

## 04. Flight Mode Management

### 04.01 Flight Mode Structure
Each flight mode contains:
- **Trim settings**: Control surface offsets
- **Curve adjustments**: Response modification
- **Switch assignments**: Feature activation
- **Safety settings**: Failsafe behavior

### 04.02 Mode Switching Logic
- **Switch-based**: Physical switch activation
- **Automatic**: Based on flight conditions
- **Priority system**: Higher modes override lower
- **Fallback protection**: Safe mode reversion

## 05. Safety Systems

### 05.01 Arming Protection
- **Throttle interlock**: Prevents arming with throttle up
- **Switch combination**: Multi-step arming sequence
- **Throttle cutoff**: Emergency power shutdown
- **Failsafe**: Automatic safe state on signal loss

### 05.02 Failsafe Configuration
- **Hold last position**: Maintain current settings
- **Set to predefined**: Custom safe positions
- **No pulses**: Emergency shutdown
- **Receiver-specific**: Hardware-dependent behavior

## 06. ExpressLRS Integration

### 06.01 Protocol Features
- **Frequency hopping**: Interference avoidance
- **Adaptive power**: Range optimization
- **Telemetry**: Real-time data feedback
- **Binding security**: Encrypted connections

### 06.02 Configuration Options
- **Packet rate**: Update frequency (50Hz-500Hz)
- **Power levels**: Transmission strength
- **Switch modes**: Channel configuration
- **Model match**: Security binding

## 07. Lua Scripting Capabilities

### 07.01 Script Types
- **Functions**: Custom calculations and logic
- **Mixes**: Advanced mixing algorithms
- **Telemetry**: Data processing and display
- **One-time**: Setup and initialization

### 07.02 Common Applications
- **Mode switching**: Complex flight mode logic
- **Telemetry display**: Custom data visualization
- **Safety systems**: Enhanced protection features
- **Automation**: Flight assistance functions

## 08. Telemetry System

### 08.01 Data Sources
- **Receiver telemetry**: Signal quality, voltage
- **Flight controller**: Attitude, battery, GPS
- **Sensors**: Temperature, current, altitude
- **Custom sensors**: Application-specific data

### 08.02 Display Configuration
- **Screens**: Multiple telemetry pages
- **Widgets**: Visual data representation
- **Alarms**: Threshold-based alerts
- **Logging**: Data recording for analysis

## 09. Configuration Management

### 09.01 Version Control
- **YAML export/import**: Human-readable configuration
- **Backup strategies**: Multiple recovery options
- **Change tracking**: Modification history
- **Template system**: Reusable configurations

### 09.02 Synchronization
- **Digital twin**: Repository-based configuration
- **Bidirectional sync**: Radio ↔ computer updates
- **Conflict resolution**: Change merging logic
- **Validation**: Configuration integrity checks

## 10. Advanced Features

### 10.01 Global Functions
- **Channel overrides**: Runtime modifications
- **Trim step adjustment**: Precision control
- **Throttle warning**: Low power alerts
- **Switch warnings**: Configuration verification

### 10.02 Special Functions
- **Play sound**: Audio feedback
- **Adjust GV**: Global variable modification
- **Override channel**: Direct servo control
- **Set failsafe**: Runtime safety adjustment

## 11. Hardware-Specific Considerations

### 11.01 RadioMaster TX15 Features
- **Hall-effect sticks**: Precise, no-center control
- **High-contrast screen**: Excellent visibility
- **USB-C connectivity**: Fast data transfer
- **Internal module bay**: ExpressLRS compatibility

### 11.02 Receiver Compatibility
- **CRSF protocol**: Full telemetry support
- **PWM output**: Traditional servo control
- **SBUS/PPM**: Alternative protocols
- **Diversity antennas**: Improved signal reliability

## 12. Best Practices

### 12.01 Configuration Workflow
1. **Plan**: Define requirements and constraints
2. **Template**: Start from proven configurations
3. **Customize**: Adapt to specific aircraft
4. **Test**: Verify functionality incrementally
5. **Document**: Record changes and reasoning

### 12.02 Maintenance Procedures
- **Regular backups**: Prevent configuration loss
- **Firmware updates**: Stay current with improvements
- **Hardware checks**: Verify component functionality
- **Performance monitoring**: Track and optimize settings

### 12.03 Troubleshooting Methodology
1. **Isolate issues**: Test components individually
2. **Compare configurations**: Reference known working setups
3. **Review logs**: Analyze telemetry and system data
4. **Community consultation**: Leverage collective experience