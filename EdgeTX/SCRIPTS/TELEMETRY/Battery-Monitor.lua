-- Battery Monitor Script for EdgeTX
-- Monitors battery voltage, current, and capacity for RC aircraft

-- Script properties
local scriptName = "Battery Monitor"
local scriptVersion = "1.0"

-- Configuration
local VOLTAGE_SENSOR = "RxBt"      -- CRSF battery voltage sensor
local CURRENT_SENSOR = "Curr"      -- Current sensor (if available)
local CAPACITY_SENSOR = "Capa"     -- Capacity sensor (if available)

-- Battery specifications (customize per aircraft)
local BATTERY_CONFIG = {
    cellCount = 2,                 -- Number of cells
    cellMinVoltage = 3.3,          -- Minimum cell voltage
    cellMaxVoltage = 4.2,          -- Maximum cell voltage
    capacityMah = 450,             -- Battery capacity in mAh
    dischargeRate = 25,            -- Maximum discharge rate (C rating)
}

-- Warning thresholds
local WARNING_THRESHOLDS = {
    voltageLow = 3.5,              -- Low voltage warning (per cell)
    voltageCritical = 3.3,         -- Critical voltage alarm (per cell)
    capacityLow = 20,              -- Low capacity warning (%)
    capacityCritical = 10,         -- Critical capacity alarm (%)
}

-- Global variables
local lastVoltage = 0
local lastCurrent = 0
local lastCapacity = 0
local minVoltage = 999
local maxCurrent = 0
local flightStartCapacity = 0
local flightStartTime = 0

-- Initialize script
local function init()
    print(scriptName .. " v" .. scriptVersion .. " initialized")

    -- Initialize flight start values
    flightStartTime = getTime()
    flightStartCapacity = getValue(CAPACITY_SENSOR) or BATTERY_CONFIG.capacityMah
end

-- Get battery voltage in volts
local function getBatteryVoltage()
    local voltage = getValue(VOLTAGE_SENSOR)
    if voltage and voltage > 0 then
        lastVoltage = voltage / 100  -- Convert from centivolts to volts
        minVoltage = math.min(minVoltage, lastVoltage)
        return lastVoltage
    end
    return lastVoltage
end

-- Get current in amps
local function getCurrent()
    local current = getValue(CURRENT_SENSOR)
    if current and current > 0 then
        lastCurrent = current / 100  -- Convert from centiamps to amps
        maxCurrent = math.max(maxCurrent, lastCurrent)
        return lastCurrent
    end
    return lastCurrent
end

-- Get remaining capacity in mAh
local function getCapacity()
    local capacity = getValue(CAPACITY_SENSOR)
    if capacity and capacity > 0 then
        lastCapacity = capacity
        return lastCapacity
    end
    return flightStartCapacity  -- Fallback to initial capacity
end

-- Calculate cell voltage
local function getCellVoltage()
    local batteryVoltage = getBatteryVoltage()
    return batteryVoltage / BATTERY_CONFIG.cellCount
end

-- Calculate capacity percentage
local function getCapacityPercent()
    local currentCapacity = getCapacity()
    return (currentCapacity / BATTERY_CONFIG.capacityMah) * 100
end

-- Calculate power consumption in watts
local function getPowerConsumption()
    local voltage = getBatteryVoltage()
    local current = getCurrent()
    return voltage * current
end

-- Calculate flight time remaining (rough estimate)
local function getTimeRemaining()
    local currentCapacity = getCapacity()
    local current = getCurrent()

    if current > 0 and currentCapacity > 0 then
        -- Time remaining in seconds
        return (currentCapacity / (current * 1000)) * 3600
    end

    return 0
end

-- Check for warnings and alarms
local function checkWarnings()
    local warnings = {}

    local cellVoltage = getCellVoltage()
    local capacityPercent = getCapacityPercent()

    -- Voltage warnings
    if cellVoltage <= WARNING_THRESHOLDS.voltageCritical then
        table.insert(warnings, "CRITICAL VOLTAGE")
    elseif cellVoltage <= WARNING_THRESHOLDS.voltageLow then
        table.insert(warnings, "LOW VOLTAGE")
    end

    -- Capacity warnings
    if capacityPercent <= WARNING_THRESHOLDS.capacityCritical then
        table.insert(warnings, "CRITICAL CAPACITY")
    elseif capacityPercent <= WARNING_THRESHOLDS.capacityLow then
        table.insert(warnings, "LOW CAPACITY")
    end

    -- Play alarms for critical conditions
    if #warnings > 0 then
        if warnings[1]:find("CRITICAL") then
            playTone(1200, 200, 0, PLAY_NOW)
        elseif warnings[1]:find("LOW") then
            playTone(800, 100, 0, PLAY_NOW)
        end
    end

    return warnings
end

-- Format time display (MM:SS)
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = math.floor(seconds % 60)
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

-- Main display function
local function run(event)
    -- Update sensor readings
    local voltage = getBatteryVoltage()
    local current = getCurrent()
    local capacity = getCapacity()
    local cellVoltage = getCellVoltage()
    local capacityPercent = getCapacityPercent()
    local power = getPowerConsumption()
    local timeRemaining = getTimeRemaining()

    -- Check for warnings
    local warnings = checkWarnings()

    -- Display battery information
    lcd.clear()

    -- Title
    lcd.drawText(0, 0, "Battery Monitor", INVERS)

    -- Main readings
    lcd.drawText(0, 12, string.format("Voltage: %.2fV", voltage), 0)
    lcd.drawText(0, 24, string.format("Cell: %.2fV", cellVoltage), 0)
    lcd.drawText(0, 36, string.format("Current: %.2fA", current), 0)
    lcd.drawText(0, 48, string.format("Capacity: %d%%", capacityPercent), 0)

    -- Secondary readings
    lcd.drawText(80, 12, string.format("Power: %.1fW", power), 0)
    lcd.drawText(80, 24, string.format("Remain: %s", formatTime(timeRemaining)), 0)
    lcd.drawText(80, 36, string.format("Min: %.2fV", minVoltage), 0)
    lcd.drawText(80, 48, string.format("Max: %.2fA", maxCurrent), 0)

    -- Warnings
    if #warnings > 0 then
        for i, warning in ipairs(warnings) do
            local y = 8 + (i * 8)
            if y < 64 then  -- Stay within screen bounds
                lcd.drawText(0, 56 - ((#warnings - i + 1) * 8), warning, BLINK + INVERS)
            end
        end
    end

    return 0
end

-- Background function for continuous monitoring
local function background()
    -- Continuous sensor monitoring
    checkWarnings()
end

-- Reset flight statistics
local function resetFlightStats()
    minVoltage = 999
    maxCurrent = 0
    flightStartTime = getTime()
    flightStartCapacity = getCapacity()
    print("Flight statistics reset")
end

-- Return script interface
return {
    init = init,
    run = run,
    background = background,
    resetFlightStats = resetFlightStats,
    getBatteryVoltage = getBatteryVoltage,
    getCurrent = getCurrent,
    getCapacity = getCapacity,
    getCellVoltage = getCellVoltage,
    getCapacityPercent = getCapacityPercent,
    getPowerConsumption = getPowerConsumption,
    getTimeRemaining = getTimeRemaining,
    checkWarnings = checkWarnings
}