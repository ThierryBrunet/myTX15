# Project Directory Structure – TX15 + Mixed Receivers

## Root
- README.md
- .cursor/ (this folder)
- SD_CARD/ (mirrors TX15 SD structure for easy copy)

## Subdirectories
- SD_CARD/SCRIPTS/TOOLS/
  - elrs_config_3.6.3.lua (official + any custom variants)
- SD_CARD/WIDGETS/
  - telemetry_rssi_tx15/ (color LVGL widget)
  - voltage_sag_tx15/
- models/
  - cyclone_pwm_plane/ (e.g., .otx + mixes.yaml notes)
  - hpxgrc_crsf_quad/
  - darwin_f415_aio_whoop/
- elrs_firmware/
  - targets/ (screenshots or notes: cyclone → esp8285-7pwm, etc.)
  - configurator_settings/ (JSON exports from 1.7.11)
- helpers/
  - parse_otx.py (optional Python for batch edits)

## Naming Conventions
- Files: prefix with hardware/version (e.g., model_cyclone_2120_3.6.3.otx)
- Comments: Include "Tested on EdgeTX 2.12.0 / ELRS 3.6.3"

Generate new items in correct subdirs; update structure doc as needed.