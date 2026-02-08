# Quadcopter Model Setup – Angel30 3" (DarwinFPV F415 AIO)

## 01.00.00 Model Creation Workflow

01.01.00 Create new model  
01.01.01 Select empty slot → Helicopter → New model  
01.01.02 Name: "Angel30"

01.02.00 Receiver & Binding  
01.02.01 Internal RF → ExpressLRS → Bind (use Configurator if needed)  
01.02.02 Protocol: CRSF (telemetry enabled)

01.03.00 Inputs (standard Mode 2)  
01.03.01 I1: Ail  weight 100 source RS  
01.03.02 I2: Ele  weight 100 source LS (invert if needed)  
01.03.03 I3: Thr  weight 100 source LS  
01.03.04 I4: Rud  weight 100 source RS  

01.04.00 Apply mandatory features  
01.04.01 Safe 2-step arming → see 06-safe-arming.md (quad version)  
01.04.02 Flight modes (Indoors / Outdoors / Normal) → see 07-flight-configurations.md (drone)  
01.04.03 Mode 2 ↔ Mode 4 switch → see 05-mode2-to-mode4-switch.md (assign to desired 2- or 3-position switch)

01.05.00 Outputs  
01.05.01 Channels 1-4 → motors via Betaflight (passthrough in Normal mode)  
01.05.02 Channel 6 → arming switch  
01.05.03 Channel 5 → flight mode switch (SA or SC recommended)