-- Arming Safety Check Script for EdgeTX
-- Provides enhanced safety checks for arming quadcopters and fixed-wing aircraft

-- Script properties
local scriptName = "Arming Safety Check"
local scriptVersion = "1.0"

-- Configuration
local THROTTLE_CHANNEL = 3
local ARMING_CHANNEL = 6
local THROTTLE_IDLE_THRESHOLD = 10  -- Max throttle for safe arming
local SAFETY_DELAY = 2000          -- 2 second delay before arming
local BEEP_INTERVAL = 500          -- Beep every 500ms during delay

-- Safety states
local SAFETY_STATES = {
    SAFE = 0,
    WARNING = 1,
    ARMED = 2
}

-- Global variables
local safetyState = SAFETY_STATES.SAFE
local armingStartTime = 0
local lastBeepTime = 0
local throttleAtArming = 0

-- Initialize script
local function init()
    print(scriptName .. " v" .. scriptVersion .. " initialized")
    safetyState = SAFETY_STATES.SAFE
end

-- Check throttle position for safe arming
local function isThrottleSafe()
    local throttleValue = getValue(THROTTLE_CHANNEL)
    return math.abs(throttleValue) <= THROTTLE_IDLE_THRESHOLD
end

-- Check all pre-arming conditions
local function checkPreArmConditions()
    local conditions = {
        throttleSafe = isThrottleSafe(),
        gpsLock = true,  -- Would check GPS if available
        radioLink = true, -- Would check radio link quality
        batteryOk = true  -- Would check battery voltage
    }

    return conditions
end

-- Validate arming sequence
local function validateArmingSequence()
    local currentTime = getTime()

    -- Check if throttle is at idle
    if not isThrottleSafe() then
        if safetyState ~= SAFETY_STATES.SAFE then
            safetyState = SAFETY_STATES.SAFE
            armingStartTime = 0
            playTone(800, 200, 0, PLAY_NOW)  -- Error beep
            print("Arming aborted: Throttle not at idle")
        end
        return false
    end

    -- Start arming delay
    if safetyState == SAFETY_STATES.SAFE then
        safetyState = SAFETY_STATES.WARNING
        armingStartTime = currentTime
        throttleAtArming = getValue(THROTTLE_CHANNEL)
        print("Arming sequence started")
    end

    -- Check for throttle movement during delay (safety check)
    local currentThrottle = getValue(THROTTLE_CHANNEL)
    if math.abs(currentThrottle - throttleAtArming) > 5 then
        safetyState = SAFETY_STATES.SAFE
        armingStartTime = 0
        playTone(600, 300, 0, PLAY_NOW)  -- Warning beep
        print("Arming aborted: Throttle moved during delay")
        return false
    end

    -- Progress through arming delay
    local elapsedTime = currentTime - armingStartTime

    if elapsedTime >= SAFETY_DELAY then
        safetyState = SAFETY_STATES.ARMED
        playTone(1000, 100, 0, PLAY_NOW)  -- Success beep
        print("Arming sequence completed - ARMED")
        return true
    else
        -- Beep during countdown
        if currentTime - lastBeepTime >= BEEP_INTERVAL then
            playTone(400, 50, 0, PLAY_NOW)
            lastBeepTime = currentTime
        end

        -- Calculate progress (0-100)
        local progress = math.floor((elapsedTime / SAFETY_DELAY) * 100)
        return false, progress
    end
end

-- Main script function
local function run(event)
    local conditions = checkPreArmConditions()
    local allConditionsMet = true

    -- Check each condition
    for condition, met in pairs(conditions) do
        if not met then
            allConditionsMet = false
            break
        end
    end

    if not allConditionsMet then
        safetyState = SAFETY_STATES.SAFE
        armingStartTime = 0
        return safetyState
    end

    -- Validate arming sequence
    local armed, progress = validateArmingSequence()

    -- Set arming channel based on state
    if safetyState == SAFETY_STATES.ARMED then
        -- Set arming channel to armed position
        -- This would be handled by EdgeTX mixing
    end

    -- Return status for telemetry
    return safetyState, progress or 0
end

-- Background function for continuous monitoring
local function background()
    -- Continuous safety monitoring
    local conditions = checkPreArmConditions()

    -- If conditions change while armed, this could trigger failsafe
    if safetyState == SAFETY_STATES.ARMED then
        for condition, met in pairs(conditions) do
            if not met then
                -- Trigger failsafe or warning
                playTone(1200, 500, 0, PLAY_NOW)
                print("Safety condition failed while armed: " .. condition)
                break
            end
        end
    end
end

-- Emergency disarm function
local function emergencyDisarm()
    safetyState = SAFETY_STATES.SAFE
    armingStartTime = 0
    -- Set arming channel to disarmed position
    playTone(800, 200, 0, PLAY_NOW)
    print("Emergency disarm activated")
end

-- Return script interface
return {
    init = init,
    run = run,
    background = background,
    emergencyDisarm = emergencyDisarm,
    getSafetyState = function() return safetyState end,
    getSafetyStateName = function()
        if safetyState == SAFETY_STATES.SAFE then return "SAFE"
        elseif safetyState == SAFETY_STATES.WARNING then return "ARMING"
        elseif safetyState == SAFETY_STATES.ARMED then return "ARMED"
        end
    end,
    isThrottleSafe = isThrottleSafe,
    checkPreArmConditions = checkPreArmConditions
}