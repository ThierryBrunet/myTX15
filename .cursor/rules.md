# Rules for EdgeTX + ExpressLRS Project – RadioMaster TX15 Setup

## Hardware & Version Lock-in
- Radio: RadioMaster TX15 (H7 processor, color LCD, internal 2.4 GHz ELRS module)
- EdgeTX: Latest stable non-RC = 2.12.0 (use TX15-specific builds from radiomasterrc.com if official Companion flash not yet fully supports 3.0 UI transition)
- ExpressLRS: Latest stable non-RC = 3.6.3 (avoid 4.0.x RC series for production flying)
- ELRS Configurator: Latest stable non-RC = 1.7.11 (or nearest patch)
- Receivers:
  - Cyclone PWM 7CH CRSF → Use ELRS target ≈ generic esp8285 7pwm or cyclone-specific if available; output mode = PWM + CRSF telemetry
  - HPXGRC ELRS Receiver → Standard CRSF/serial target (e.g., esp32 or esp8285 CRSF variants)
  - DarwinFPV F415 AIO → Target = darwin-f415 or equivalent F4 AIO with integrated ELRS; CRSF to FC UART

## General & Safety Rules
- Prioritize failsafes: Always configure ELRS failsafe (custom packet or no pulses) + EdgeTX channel failsafe overrides (e.g., throttle -100%, ailerons/elevator neutral).
- TX15 specifics: Leverage H7 speed → prefer LVGL-based widgets over legacy; enable haptic feedback where useful.
- Regulatory: Assume FCC region unless specified (higher power options); never exceed legal limits in code/comments.

## Lua Scripting Rules (TX15 Color Screen)
- Use 2-space indentation; full comments including hardware context.
- API: Target EdgeTX 2.12.0 Lua API (lcd, model.*, getValue for telemetry).
- ELRS integration: Use official ELRS Lua script (place in /SCRIPTS/TOOLS/); generate variants only for binding/phrase changes.
- Widgets: Prefer color, LVGL controls; limit refresh rate to avoid UI lag.
- PWM receivers (Cyclone): Scripts must not assume full telemetry if CRSF not wired; focus on channel monitoring.
- CRSF receivers (HPXGRC, Darwin F415): Full telemetry support → generate RSSI, battery, GPS scripts.

## Model Configuration Rules
- Inputs/Mixes: Use hardware name prefixes (e.g., CH1_AIL_CYCLONE, CH5_GEAR_HPXGRC).
- Flight modes: Define clear names (e.g., ACRO, STAB, RTH); include ELRS link quality checks via logical switches.
- Special Functions: Voice alerts for "ELRS RSSI <  -80 dBm", "Low Battery", "Failsafe Active".
- Telemetry: Discover sensors automatically; add custom calculated fields (e.g., mAh used if current sensor present).

## Prohibited / Risky Practices
- No 4.0.x ELRS code generation until stable.
- Avoid blocking Lua calls; test in Companion simulator first.
- Do not hard-code binding phrases → use placeholders or prompt user.
- Flag PWM vs CRSF differences in comments (e.g., "PWM-only: no telemetry fallback").

When generating, always include compatibility notes for TX15 + 2.12.0 + ELRS 3.6.3.