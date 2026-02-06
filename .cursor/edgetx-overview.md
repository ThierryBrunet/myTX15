# EdgeTX Radio Configuration Guide

## Radio Hardware
- Radio Model: [e.g., RadioMaster TX16S, Jumper T16, etc.]
- EdgeTX Version: [e.g., 2.9.x]
- Transmitter Protocol: [e.g., ELRS, FrSky, etc.]

## File Structure
- Configuration files: `.yml` or `.etx` format
- Model files location: `/MODELS/`
- Scripts location: `/SCRIPTS/`
- Sounds location: `/SOUNDS/`

## Common Patterns
- Use logical switches (L01-L32) for mode switching
- Global functions go in Special Functions, model-specific in Model settings
- Telemetry sensors named with clear prefixes (e.g., `Bat1_`, `GPS_`)