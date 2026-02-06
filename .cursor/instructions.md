# Instructions for EdgeTX & ELRS Configuration – RadioMaster TX15 Focused

## Project Scope
Generate Lua scripts, model mixes, special functions, and ELRS settings for RadioMaster TX15 running EdgeTX 2.12.0 stable + ExpressLRS 3.6.3 stable.

## Core Workflow
1. Clarify aircraft/receiver type first (Cyclone PWM plane? HPXGRC FPV quad? Darwin F415 whoop?).
2. Reference official sources: edgetx.org (2.12 docs), expresslrs.org (3.6.x targets & options).
3. Generate in steps: model basics → inputs/mixes → telemetry → special functions → Lua if needed.
4. Simulate: Recommend Companion 2.12.0 simulation; note TX15-specific UF2 flashing if needed.
5. ELRS flashing: Use Configurator 1.7.11 → select correct target → regulatory domain → bind phrase/PWR/telemetry ratio.
6. Safety first: Always include multi-layer failsafe (ELRS + EdgeTX channel FS + logical switch voice alert).

## Receiver-Specific Guidance
- Cyclone PWM 7CH CRSF: Map channels 1–7 to servos directly; CRSF telemetry optional (extra wire); ideal for fixed-wing/gliders.
- HPXGRC CRSF: Full telemetry; typical for multirotor/plane with separate FC; generate RSSI/LQ/vbat scripts.
- Darwin F415 AIO: CRSF to FC UART; focus on arm/disarm logic, flight controller passthrough; minimal onboard telemetry scripts.

## Common Tasks Examples
- ELRS Lua tool: Generate config script variant for 3.6.3 (binding, WiFi, packet rate 250Hz/500Hz/F1000).
- Model for Cyclone plane: Expo/dual rates on aileron/elevator, throttle cut SF, gear/flaps on switches.
- Telemetry screen: RSSI bar + LQ numeric + voltage (if applicable); custom color widget for TX15.
- Logical switches: L1 = !RSSI > -90 → safety override; L2 = timer1 > 00:05:00 → voice "land now".

Explore angles: safety (redundant FS), performance (packet rate vs range), usability (switch assignments), compatibility (PWM vs CRSF scripts).