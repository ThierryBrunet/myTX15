#Requires -Version 5.1
<#
.SYNOPSIS
    Configures ExpressLRS receivers via passthrough or WiFi.

.DESCRIPTION
    Generates configuration files and commands for Cyclone, HPXGRC, and DarwinFPV receivers.

.PARAMETER ReceiverType
    Type of receiver: Cyclone, HPXGRC, DarwinFPV

.PARAMETER Protocol
    Protocol mode: CRSF, PWM

.PARAMETER OutputPath
    Where to save configuration files

.EXAMPLE
    .\Set-ELRSReceiver.ps1 -ReceiverType Cyclone -Protocol CRSF
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Cyclone", "HPXGRC", "DarwinFPV")]
    [string]$ReceiverType,

    [ValidateSet("CRSF", "PWM")]
    [string]$Protocol = "CRSF",

    [string]$OutputPath = ".\ReceiverConfigs"
)

$ReceiverConfigs = @{
    Cyclone = @{
        Name = "Cyclone 2.4GHz PWM 7CH"
        Configs = @{
            CRSF = @{
                FileName = "CRSF.json"
                Content = @{
                    protocol = "CRSF"
                    channels = 7
                    pwm_frequency = 50
                    failsafe_mode = "hold"
                    output_map = @{
                        CH1 = "PWM1"
                        CH2 = "PWM2"
                        CH3 = "PWM3"
                        CH4 = "PWM4"
                        CH5 = "PWM5"
                        CH6 = "PWM6"
                        CH7 = "PWM7"
                    }
                    telemetry = @("RSSI", "LQ", "RxBt")
                }
            }
            PWM = @{
                FileName = "7CH.json"
                Content = @{
                    protocol = "PWM"
                    channels = 7
                    pwm_frequency = 50
                    failsafe_mode = "custom"
                    failsafe_values = @(-100, -100, -100, 0, -100, -100, -100)
                    output_map = @{
                        CH1 = "PWM1"
                        CH2 = "PWM2"
                        CH3 = "PWM3"
                        CH4 = "PWM4"
                        CH5 = "PWM5"
                        CH6 = "PWM6"
                        CH7 = "PWM7"
                    }
                    voltage_monitoring = $true
                    telemetry = @("RSSI", "LQ", "RxBt")
                }
            }
        }
        Flashing = @{
            Method = "ELRS Configurator"
            BaudRate = 420000
            PacketRate = "250Hz"
            TelemetryRatio = "1:64"
            SwitchMode = "Hybrid"
        }
    }

    HPXGRC = @{
        Name = "HPXGRC 2.4GHz ELRS"
        Configs = @{
            CRSF = @{
                FileName = "HPXGRC_CRSF.json"
                Content = @{
                    protocol = "CRSF"
                    channels = 6
                    pwm_frequency = 50
                    failsafe_mode = "hold"
                    output_map = @{
                        CH1 = "PWM1"
                        CH2 = "PWM2"
                        CH3 = "PWM3"
                        CH4 = "PWM4"
                        CH5 = "PWM5"
                        CH6 = "PWM6"
                    }
                    telemetry = @("RSSI", "LQ")
                }
            }
        }
        Flashing = @{
            Method = "ELRS Configurator"
            BaudRate = 420000
            PacketRate = "500Hz"
            TelemetryRatio = "1:128"
            SwitchMode = "Hybrid"
        }
    }

    DarwinFPV = @{
        Name = "DarwinFPV F415 AIO"
        Description = "Integrated ELRS on F4 FC - configure via Betaflight"
        BetaflightConfig = @"
# DarwinFPV F415 AIO Configuration
# Paste these commands into Betaflight CLI

# Serial port for ELRS (UART1 typically)
serial 0 64 115200 57600 0 115200

# Receiver protocol
set serialrx_provider = CRSF
set serialrx_inverted = OFF
set serialrx_halfduplex = OFF

# Arming safety
set small_angle = 180
set auto_disarm_delay = 5

# Failsafe settings
set failsafe_delay = 5
set failsafe_off_delay = 0
set failsafe_throttle = 1000
set failsafe_switch_mode = STAGE1
set failsafe_procedure = DROP

# Mode assignments (adjust AUX channels as needed)
aux 0 0 0 900 2100 0 0  # ARM on AUX1 (CH5)
aux 1 1 1 1300 1700 0 0  # ANGLE on AUX2 mid
aux 2 2 1 1700 2100 0 0  # HORIZON on AUX2 high
aux 3 13 2 1700 2100 0 0  # BEEPER on AUX3
aux 4 35 3 1700 2100 0 0  # TURTLE on AUX4 (if needed)

# Motor protocol (DShot300 for this AIO)
set motor_pwm_protocol = DSHOT300

# Save
save
"@
        Flashing = @{
            Method = "Betaflight Passthrough"
            Notes = "Use ELRS Configurator with Betaflight passthrough option"
        }
    }
}

Write-Host "ELRS Receiver Configuration" -ForegroundColor Cyan
Write-Host "Receiver: $($ReceiverConfigs[$ReceiverType].Name)" -ForegroundColor Gray
Write-Host "Protocol: $Protocol" -ForegroundColor Gray
Write-Host ""

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$receiver = $ReceiverConfigs[$ReceiverType]

# Handle DarwinFPV specially (Betaflight-based)
if ($ReceiverType -eq "DarwinFPV") {
    $bfFile = Join-Path $OutputPath "DarwinFPV_F415_Config.txt"
    $receiver.BetaflightConfig | Out-File $bfFile -Encoding UTF8

    Write-Host "Betaflight configuration saved to: $bfFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "Flashing Instructions:" -ForegroundColor Yellow
    Write-Host "1. Connect to Betaflight Configurator" -ForegroundColor White
    Write-Host "2. Go to CLI tab" -ForegroundColor White
    Write-Host "3. Paste commands from config file" -ForegroundColor White
    Write-Host "4. Type 'save' and press Enter" -ForegroundColor White
    Write-Host ""
    Write-Host "To update ELRS firmware:" -ForegroundColor Yellow
    Write-Host "1. Use ELRS Configurator" -ForegroundColor White
    Write-Host "2. Select 'Betaflight Passthrough'" -ForegroundColor White
    Write-Host "3. Select correct UART (usually UART1)" -ForegroundColor White
    exit 0
}

# Generate JSON config for standard receivers
$config = $receiver.Configs[$Protocol]
if (-not $config) {
    Write-Error "Protocol '$Protocol' not available for $ReceiverType"
    exit 1
}

$jsonFile = Join-Path $OutputPath $config.FileName
$config.Content | ConvertTo-Json -Depth 10 | Out-File $jsonFile -Encoding UTF8

Write-Host "Configuration saved to: $jsonFile" -ForegroundColor Green
Write-Host ""
Write-Host "Receiver Settings:" -ForegroundColor Cyan
Write-Host "  Method: $($receiver.Flashing.Method)" -ForegroundColor White
Write-Host "  Packet Rate: $($receiver.Flashing.PacketRate)" -ForegroundColor White
Write-Host "  Telemetry: $($receiver.Flashing.TelemetryRatio)" -ForegroundColor White
Write-Host "  Switch Mode: $($receiver.Flashing.SwitchMode)" -ForegroundColor White
Write-Host ""
Write-Host "Flashing Steps:" -ForegroundColor Yellow
Write-Host "1. Open ELRS Configurator" -ForegroundColor White
Write-Host "2. Select target: $ReceiverType" -ForegroundColor White
Write-Host "3. Set Packet Rate: $($receiver.Flashing.PacketRate)" -ForegroundColor White
Write-Host "4. Flash via $($receiver.Flashing.Method)" -ForegroundColor White
