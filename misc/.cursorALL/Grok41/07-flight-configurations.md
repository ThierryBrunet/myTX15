# Flight Configurations

## Quadcopter (3 modes on one 3-position switch, e.g., SA)
- SA↑ = Indoors: Rates 50%, Expo 50% on Ail/Ele/Rud, max throttle 60%
- SA mid = Outdoors: Rates 70%, Expo 30%, max throttle 80%
- SA↓ = Normal: Rates 100%, Expo as per Betaflight, throttle passthrough

Use Global Functions or Mixes with switch conditions to scale weights.

## Fixed Wing (Reflex V3 – 3-position switch on Channel 5)
- Position 1 (-100): Beginner (full stabilization + auto-level)
- Position 2 (0):   Advanced (gyro stabilization only)
- Position 3 (+100): Full Manual (gyro off)

Typical PWM values for Reflex V3:
- < 1300µs → Off/Manual
- 1300–1700µs → Stabilization
- > 1700µs → 3D/Optimized or Beginner
Adjust switch direction to match airframe preference.

