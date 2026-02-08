-- Mode 2 to Mode 4 Switch Script for EdgeTX
-- Implements dynamic switching between Mode 2 and Mode 4 control schemes
-- Reference: https://www.youtube.com/watch?v=kiKQy736huM

-- Script properties
local scriptName = "Mode2To4 Switch"
local scriptVersion = "1.0"

-- Configuration
local MODE_SWITCH = "SE"  -- Switch used for mode selection
local MODE2_TRIM = "T1"   -- Elevator trim for Mode 2
local MODE4_TRIM = "T2"   -- Throttle trim for Mode 4
local MIX_WEIGHT = 100    -- Mix weight for channel remapping

-- Global variables
local currentMode = 2  -- Default to Mode 2
local modeChanged = false
local lastSwitchState = 0

-- Mode definitions
local MODES = {
    [2] = {
        name = "Mode 2",
        elevatorTrim = "T1",
        throttleTrim = "T3",
        description = "Elevator on left stick, Throttle on right stick"
    },
    [4] = {
        name = "Mode 4",
        elevatorTrim = "T3",
        throttleTrim = "T1",
        description = "Throttle on left stick, Elevator on right stick"
    }
}

-- Initialize script
local function init()
    -- Register special function for mode switching
    -- This would typically be done in EdgeTX Companion
    print(scriptName .. " v" .. scriptVersion .. " initialized")
end

-- Get switch state
local function getSwitchState(switchName)
    local switchValue = getValue(switchName)
    if switchValue > 100 then
        return 1  -- Up position
    elseif switchValue < -100 then
        return -1  -- Down position
    else
        return 0  -- Middle position
    end
end

-- Detect mode change
local function detectModeChange()
    local switchState = getSwitchState(MODE_SWITCH)

    if switchState ~= lastSwitchState then
        if switchState == 1 then
            currentMode = 4  -- Switch to Mode 4
            modeChanged = true
            print("Switched to Mode 4")
        elseif switchState == -1 then
            currentMode = 2  -- Switch to Mode 2
            modeChanged = true
            print("Switched to Mode 2")
        end
        lastSwitchState = switchState
    end
end

-- Apply mode-specific mixing
local function applyModeMixing()
    local mode = MODES[currentMode]

    if currentMode == 4 then
        -- Mode 4: Throttle on left stick (CH3), Elevator on right stick (CH2)
        -- This requires remapping channels in EdgeTX Companion
        -- Left stick vertical (CH3) = Throttle
        -- Right stick vertical (CH2) = Elevator
        -- Left stick horizontal (CH1) = Aileron
        -- Right stick horizontal (CH4) = Rudder

        -- Set trims for Mode 4
        setStickySwitch(mode.elevatorTrim, getValue(mode.elevatorTrim))
        setStickySwitch(mode.throttleTrim, getValue(mode.throttleTrim))

    elseif currentMode == 2 then
        -- Mode 2: Elevator on left stick (CH2), Throttle on right stick (CH3)
        -- Left stick vertical (CH2) = Elevator
        -- Right stick vertical (CH3) = Throttle
        -- Left stick horizontal (CH1) = Aileron
        -- Right stick horizontal (CH4) = Rudder

        -- Set trims for Mode 2
        setStickySwitch(mode.elevatorTrim, getValue(mode.elevatorTrim))
        setStickySwitch(mode.throttleTrim, getValue(mode.throttleTrim))
    end
end

-- Main script function
local function run(event)
    -- Detect mode changes
    detectModeChange()

    -- Apply mode-specific settings
    applyModeMixing()

    -- Reset change flag
    if modeChanged then
        modeChanged = false
    end

    -- Return mode indicator for telemetry screen
    return currentMode
end

-- Background function (called periodically)
local function background()
    -- Continuous mode monitoring
    detectModeChange()
end

-- Return script interface
return {
    init = init,
    run = run,
    background = background,
    getCurrentMode = function() return currentMode end,
    getModeName = function() return MODES[currentMode].name end,
    getModeDescription = function() return MODES[currentMode].description end
}