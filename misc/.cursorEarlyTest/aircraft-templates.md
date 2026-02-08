# Aircraft Configuration Templates

## Fixed Wing Template
````yaml
model_name: "Generic Plane"
channels:
  - CH1: Aileron
  - CH2: Elevator
  - CH3: Throttle
  - CH4: Rudder
  - CH5: Flaps
  - CH6: Gear

mixes:
  - Aileron differential: 25%
  - Flaperons: Optional
  - Crow braking: CH5 + elevator

flight_modes:
  - FM0: Normal
  - FM1: Landing (flaps deployed)
  - FM2: Acro (high rates)
````

## Quadcopter Template
````yaml
model_name: "Generic Quad"
channels:
  - CH1: Roll
  - CH2: Pitch
  - CH3: Throttle
  - CH4: Yaw
  - CH5: Arm switch
  - CH6: Flight mode
  - CH7: Beeper
  - CH8: Turtle mode

logical_switches:
  - L01: Throttle > 10% (for safe arming)
  - L02: Arm switch ON
  
special_functions:
  - SF1: Play sound on arm (L02)
  - SF2: Throttle cut on disarm (!L02)
````

## 3. `mixing-patterns.md` - Common Mixing Scenarios
````markdown
# EdgeTX Mixing Patterns

## V-Tail Mixing
````
Left V-Tail (CH2):
- Source: Elevator, Weight: 100%, Offset: 0
- Source: Rudder, Weight: 50%, Multiplex: Add

Right V-Tail (CH4):
- Source: Elevator, Weight: 100%, Offset: 0
- Source: Rudder, Weight: -50%, Multiplex: Add
````

## Differential Thrust (Twin Motor)
````
Left Motor (CH3):
- Source: Throttle, Weight: 100%
- Source: Rudder, Weight: 25%, Multiplex: Add

Right Motor (CH7):
- Source: Throttle, Weight: 100%
- Source: Rudder, Weight: -25%, Multiplex: Add
````

## Flaperons
````
Left Flap/Aileron (CH6):
- Source: Aileron, Weight: 100%
- Source: Flap switch, Weight: 50%, Multiplex: Add

Right Flap/Aileron (CH7):
- Source: Aileron, Weight: -100%
- Source: Flap switch, Weight: 50%, Multiplex: Add
````
````

## 4. `logical-switches-cookbook.md` - Logic Recipes
````markdown
# Logical Switch Cookbook

## Safety: Throttle Hold Until Armed
````
L01: Arm switch = ON
SF1: CH3 (Throttle) Override -100 when !L01
````

## Timer: Flight Time (Only When Armed + Throttle Active)
````
L01: Arm switch = ON
L02: Throttle > 5%
L03: L01 AND L02
Timer1: Trigger on L03
````

## Alert: Low Battery Warning
````
L04: Battery voltage < 3.3V per cell
SF1: Play sound "lowbat.wav" when L04
SF2: Vibrate when L04
````

## Mode Switching: 3-Position Switch to 5 Flight Modes
````
L05: SA down
L06: SA middle  
L07: SA up
L08: SB down
L09: SB up

FM0: !L05 AND !L06 AND !L07  (default)
FM1: L05 AND !L08
FM2: L06 AND !L08
FM3: L07 OR L08
FM4: L09
````
````

## 5. `telemetry-setup.md` - Sensor Configuration
````markdown
# Telemetry Sensor Configuration

## ELRS (ExpressLRS) Standard Sensors
- RSSI: Link quality
- RSNR: Signal-to-noise ratio
- ANT: Active antenna
- RFMD: RF mode (rate)
- TPWR: TX power
- TRSS: TX RSSI

## Common Calculated Sensors
```yaml
Bat1_Capacity:
  formula: "Consumption / 1000"
  unit: "Ah"
  
Bat1_Remaining:
  formula: "(BatteryCapacity - Bat1_Capacity) / BatteryCapacity * 100"
  unit: "%"
  
Flight_Time:
  formula: "Timer1"
  unit: "s"
  
Distance_Home:
  formula: "sqrt(GPS_DistN^2 + GPS_DistE^2)"
  unit: "m"
```

## Voice Alerts
````
Create logical switches:
- L10: Bat1_Remaining < 50%
- L11: Bat1_Remaining < 30%
- L12: Bat1_Remaining < 20%

Special Functions:
- SF10: Play "bat50.wav" once when L10 activates
- SF11: Play "bat30.wav" repeat when L11
- SF12: Play "critical.wav" + vibrate when L12
````
````

## 6. `lua-scripting.md` - Custom Script Patterns
````markdown
# EdgeTX Lua Scripting Guide

## Script Locations
- Widget scripts: `/WIDGETS/`
- Telemetry scripts: `/SCRIPTS/TELEMETRY/`
- Function scripts: `/SCRIPTS/FUNCTIONS/`
- One-time scripts: `/SCRIPTS/TOOLS/`

## Basic Widget Template
```lua
local function create()
  return {}
end

local function update(widget, options)
  -- Update logic
end

local function background(widget)
  -- Background processing
end

local function refresh(widget)
  lcd.clear()
  -- Draw UI
end

return { 
  name="MyWidget", 
  create=create, 
  update=update, 
  background=background, 
  refresh=refresh 
}
```

## Common Telemetry Functions
```lua
-- Get telemetry value
local rssi = getValue("RSSI")
local voltage = getValue("RxBt")

-- Get switch position
local switchSA = getValue("sa")

-- Play sound
playFile("/SOUNDS/en/alert.wav")

-- Haptic feedback
playHaptic(200, 0) -- duration, pause
```
````

## 7. `.cursorrules` - AI Instructions
````markdown
# EdgeTX Configuration Rules

When working with EdgeTX radio configurations:

1. **Always validate channel assignments** - Ensure channels match receiver expectations
2. **Use descriptive names** - Models, mixes, and switches should have clear names
3. **Safety first** - Include throttle cuts, arm switches, and failsafe configurations
4. **Document complex mixes** - Add comments explaining non-obvious mixing logic
5. **Test incrementally** - When modifying configs, change one thing at a time
6. **Backup before changes** - Assume user wants to preserve working configurations
7. **Follow YAML format** - Use consistent indentation (2 spaces)
8. **Include units** - Specify percentages, degrees, or absolute values clearly
9. **Logical switch naming** - Use prefix conventions (L01-L32 for switches)
10. **Voice alerts** - Suggest audio feedback for critical events

## File Generation
- Generate `.yml` files for model configurations
- Create Lua scripts with proper EdgeTX API usage
- Include comments explaining each section

## Common Pitfalls to Avoid
- Forgetting to set failsafe values
- Missing throttle cut on disarm
- Incorrect servo reversing
- Overlapping logical switch conditions
- Missing trim settings for new models
````

These instruction files would help Claude understand your EdgeTX workflow and generate more accurate, safe, and well-structured radio configurations. You can customize them based on your specific radio models and typical aircraft types.