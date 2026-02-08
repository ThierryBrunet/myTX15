# RC Transmitter Setup and Configuration Instructions

## 01. Initial Setup

### 01.01 Hardware Preparation
1. **Transmitter Setup**:
   - Ensure RadioMaster TX15 is charged and functional
   - Verify EdgeTX firmware is latest non-RC version
   - Confirm ExpressLRS firmware compatibility

2. **Receiver Configuration**:
   - **Cyclone Receiver**: Choose 7CH.json (PWM) or CRSF.json (CRSF) based on flight controller requirements
   - **HPXGRC Receiver**: Standard ExpressLRS configuration
   - **DarwinFPV F415**: Integrated ELRS configuration for quadcopters

3. **Gyroscope Installation**:
   - **Reflex V3**: Primary for fixed-wing stability
   - **ICM-20948**: Preferred for fixed-wing applications
   - **ICM-45686**: Preferred for high-vibration quadcopters

### 01.02 Software Installation
1. **ExpressLRS Companion**: Install latest non-RC version
2. **PowerShell Scripts**: Place synchronization scripts in `PowerShell/` directory
3. **Python Tools**: Install required dependencies for Python utilities

## 02. Folder Structure Setup

### 02.01 Create Required Directories
```
EdgeTX/                    # Digital twin root
├── MODELS/               # Aircraft model files
├── SCRIPTS/              # Lua scripts
├── LOGS/                 # Flight logs
└── RADIO/                # Radio configuration

PowerShell/               # Synchronization scripts
├── Sync-TX15ToUsb.ps1    # Sync to radio
├── Sync-UsbToTX15.ps1    # Sync from radio
├── Sync-TX15ToUsb-Mirror.ps1  # Mirror to radio
└── Sync-UsbToTX15-Mirror.ps1  # Mirror from radio
```

### 02.02 Initialize Git Repository
```powershell
git init
git add .
git commit -m "Initial RC transmitter digital twin setup"
```

## 03. Aircraft Model Creation

### 03.01 Quadcopter Models

#### Angel30 3-inch Carbon Fiber Frame
1. **Model Creation**:
   - Create new model in EdgeTX Companion
   - Set model type: Quadcopter
   - Configure receiver: DarwinFPV F415 AIO

2. **Arming Configuration**:
   - **Pre-arm**: Throttle minimum + Switch SA up
   - **Arm**: Additional confirmation with Switch SB up
   - **Throttle cutoff**: Automatic disarm safety

3. **Flight Modes**:
   - **Indoors**: Reduced rates (50-70%), gentle response
   - **Outdoors**: Moderate rates (70-85%), balanced control
   - **Normal**: Full rates (100%), Betaflight passthrough

### 03.02 Fixed-Wing Models

#### Flying Bear Fx707s
1. **Model Creation**:
   - Create new model in EdgeTX Companion
   - Set model type: Airplane (Flying-wing)
   - Configure receiver: Cyclone (CRSF) or HPXGRC

2. **Arming Configuration** (Non-channel 5 dependent):
   - **Pre-arm**: Throttle minimum + Switch SF up
   - **Arm**: Switch SG up for confirmation
   - **Throttle cutoff**: Independent safety circuit

3. **Flight Modes** (Reflex V3 Compatible):
   - **Beginner**: Maximum gyro stabilization
   - **Advanced**: Moderate gyro assistance
   - **Full Manual**: Minimal gyro intervention

#### 50CM Big Foam Plane
1. **Model Setup**: Follow Fx707s procedure
2. **Receiver Options**: Cyclone PWM or CRSF configuration
3. **Gyro Integration**: ICM-20948 for optimal performance

#### EDGE540 EPP F3P
1. **Model Setup**: Advanced aerobatic configuration
2. **Receiver**: Cyclone CRSF for precision control
3. **Gyro**: Reflex V3 for stability augmentation

## 04. Transmitter Configuration

### 04.01 Mode Switching Setup
1. **Implement Mode 2 to Mode 4 switching**:
   - Create logical switch for mode conversion
   - Assign to physical switch (recommended: SE)
   - Test switching functionality thoroughly

2. **Channel Mapping**:
   - Channel 1: Aileron
   - Channel 2: Elevator
   - Channel 3: Throttle
   - Channel 4: Rudder
   - Channel 5+: Flight modes, arming, auxiliary functions

### 04.02 Safety Features
1. **Throttle Cutoff**: Configure for all models
2. **Failsafe Settings**: Set appropriate failsafe positions
3. **Range Check**: Perform pre-flight range verification

## 05. Synchronization Procedures

### 05.01 Sync Modes Overview
- **SyncToRadio**: Updates radio with new/changed files, preserves existing
- **SyncFromRadio**: Updates repository with new/changed files from radio
- **MirrorToRadio**: Exact copy to radio, removes files not in repository
- **MirrorFromRadio**: Exact copy from radio, removes files not on radio

### 05.02 Execution Steps
1. **Connect TX15**: Mount SD card to computer as drive "d:\"
2. **Run Synchronization**:
   ```powershell
   # Choose appropriate sync script
   .\PowerShell\Sync-TX15ToUsb.ps1       # Update radio
   .\PowerShell\Sync-UsbToTX15.ps1       # Update repository
   ```
3. **Verify Changes**: Confirm files transferred correctly
4. **Safety Check**: Test transmitter functionality after sync

## 06. Flight Testing Protocol

### 06.01 Pre-Flight Checks
1. **Hardware Inspection**: Verify all connections
2. **Range Test**: Confirm signal integrity at maximum range
3. **Control Surface Check**: Verify servo movement and direction
4. **Arming Test**: Confirm safe arming sequence
5. **Throttle Test**: Verify cutoff functionality

### 06.02 Flight Testing Sequence
1. **Beginner Mode**: Short test flights to verify stability
2. **Progressive Testing**: Gradually increase complexity
3. **Emergency Procedures**: Practice failsafe and cutoff responses
4. **Data Logging**: Record flight performance for analysis

## 07. Maintenance and Updates

### 07.01 Firmware Updates
1. **EdgeTX Updates**: Check for latest non-RC versions
2. **ExpressLRS Updates**: Update transmitter and receivers
3. **Gyroscope Firmware**: Update Reflex V3 via FMS website

### 07.02 Configuration Backup
1. **Regular Backups**: Sync to repository after changes
2. **Version Control**: Use git for configuration history
3. **Documentation**: Update instructions as procedures evolve

## 08. Troubleshooting

### 08.01 Common Issues
- **Binding Problems**: Verify ExpressLRS version compatibility
- **Arming Failures**: Check switch assignments and throttle position
- **Flight Mode Issues**: Confirm logical switch configurations
- **Sync Errors**: Verify drive letter and file permissions

### 08.02 Diagnostic Procedures
1. **Hardware Testing**: Isolate components for testing
2. **Configuration Verification**: Compare with known working setups
3. **Log Analysis**: Review EdgeTX logs for error patterns
4. **Community Support**: Consult RC forums for complex issues