# General EdgeTX Configuration Rules for RadioMaster TX15

## Folder and File Naming
- Follow official EdgeTX SD card structure exactly:
  - Root of SD card (D:\) contains folders: MODELS, SOUNDS, THEMES, LOGS, SCRIPTS, WIDGETS, etc.
  - Model files: `/MODELS/modelXX.yml` (EdgeTX uses YAML since v2.9+)
  - Sounds: `/SOUNDS/en/SYSTEM` for system, `/SOUNDS/en` for custom
- ExpressLRS backpack/target files follow ExpressLRS repository naming (e.g., `Radiomaster_TX15_2400_ELRS.lua` if required).

## Model Creation Principles
- Always start from a clean model slot.
- Bind using ExpressLRS Configurator first (Wi-Fi or USB passthrough).
- Receiver type determines outputs:
  - DarwinFPV F415 AIO → CRSF protocol, full telemetry
  - Cyclone → choose PWM 7CH (7CH.json) or CRSF (CRSF.json) during flashing
  - HPXGRC → CRSF recommended
- Include the following mandatory features in every new or edited model:
  - Safe arming (see 06-safe-arming.md)
  - Flight mode configurations (see 07-flight-configurations.md)
  - Mode 2 ↔ Mode 4 switch override (see 05-mode2-to-mode4-switch.md)