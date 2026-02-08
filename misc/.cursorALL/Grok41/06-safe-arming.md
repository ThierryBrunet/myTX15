# Safe Arming Patterns

## Quadcopter (DarwinFPV F415 / Betaflight best practices)
- Use 2-step arming:
  - Pre-arm: 3-position switch (e.g., SA) middle = pre-arm
  - Arm: Momentary switch (SH↓) while pre-armed and throttle low
- Logical switches:
  - L1: a=x Thr < -95 (throttle low)
  - L2: AND SA↑ L1 (pre-arm condition)
  - L3: Momentary SH↓ AND L2
- Mix on CH5 or CH6: Replace source with MAX when L3 active (arm signal 2000µs), else -2000µs
- Throttle cut: separate SH momentary to force throttle -100

## Fixed Wing
- Do NOT block Channel 5 (reserved for Reflex modes)
- Use Channel 6 (or other free channel):
  - 2-position switch (e.g., SC) for arm
  - Logical switch L1: SC↓ AND Thr < -90
  - Override CH3 (throttle): -100 when !L1, normal otherwise
- Separate throttle-cut switch (SH momentary) → override CH3 to -100
