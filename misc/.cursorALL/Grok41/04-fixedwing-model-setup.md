# Fixed-Wing Model Setup Template

Use this template for:
- Flying Bear Fx707s (foamy electric conversion)
- 50CM Big Foam Plane (electric conversion)
- EDGE540 EPP F3P (flat foamy)

## 01.00.00 Model Creation Workflow

01.01.00 Create new model  
01.01.01 Select empty slot → Airplane → New model  
01.01.02 Name: "Fx707s" / "50cmFoam" / "EDGE540"

01.02.00 Receiver  
01.02.01 For PWM receivers (Cyclone 7CH): External RF off, use SBUS-to-PWM or direct PWM  
01.02.02 For CRSF receivers: Internal RF → ExpressLRS → CRSF

01.03.00 Inputs (standard Mode 2)  
01.03.01 Same as quadcopter 01.03.00 section

01.04.00 Mandatory features  
01.04.01 Safe 2-step arming → see 06-safe-arming.md (fixed-wing version – do NOT use Channel 5)  
01.04.02 Reflex V3 gyro modes (Beginner / Advanced / Full Manual) → see 07-flight-configurations.md (fixed-wing) – assign to Channel 5 (3-position switch)  
01.04.03 Mode 2 ↔ Mode 4 switch → see 05-mode2-to-mode4-switch.md

01.05.00 Outputs & Mixes  
01.05.01 Typical fixed-wing: CH1 Aileron(s), CH2 Elevator, CH3 Throttle, CH4 Rudder  
01.05.02 Add flaperon/elevon mixing if required for the airframe  
01.05.03 Throttle cut → assign to throttle-cut switch (usually SH momentary)
