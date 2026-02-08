# PROMPT

- Directives for configuring RC transmitter and aircraft models via Cursor. 
- Generate instructions/rules/skills (i.e. .md files ) to be added to the .cursor folder.
- Generate tools/utilities in PowerShell or Python, whichever is more suited for the required task.


## Tools/Utilities/Workflows

- Powershell prefered if Python provides same outcome.
- adopt the WBS pattern:
    - xx numbering for level 1, xx starting from 01.
    - xx.yy numbering for level 2, yy starting from 01.
    - xx.yy.zz numbering for level 3, zz starting from 01.
    - etc. for deeper levels.


## Transmitter

- RC radio = RadioMaster TX15.


## Open Source Software on GitHub

- EdgeTX version = Latest non-RC version for TX15.
- ELRS version = Latest non-RC version.
- ExpressLRS Companion = Latest non-RC version.


## Receivers

- receiver hardware 1 = AliExpress ELRS 2.4Ghz PWM 7CH CRSF Receiver (AKA Cyclone) -- https://www.aliexpress.com/item/1005007033545569.html?spm=a2g0o.order_list.order_list_main.27.41aa1802kgOMzU .

- receiver hardware 2 = HPXGRC 2.4G ExpressLRS ELRS Receiver -- https://www.aliexpress.com/item/1005009645506956.html?spm=a2g0o.order_list.order_list_main.22.41aa1802kgOMzU .

- receiver hardware 3 = DarwinFPV F415 AIO Flight Controller F4 2.4G ExpressLRS FC 4In1 ESC -- https://www.aliexpress.com/item/1005009990173646.html?spm=a2g0o.order_list.order_list_main.11.41aa1802kgOMzU .

- for the Cyclone receiver, note the configuration files for PWM 7CH (7CH.json) or CRSF (CRSF.json).


## Gyroscopes

- Reflex V3 Flight Controller Gyro Stabilizer  -- https://www.aliexpress.com/item/1005010233202104.html?spm=a2g0o.productlist.main.21.6d711c45LwSN12 -- firmware upgrade at www.fmsmodel.com/page/reflex

- ICM-20948 Module 9 Axis MEMS -- https://www.aliexpress.com/item/1005010143994669.html?spm=a2g0o.cart.0.0.c11638da1wq6Nm -- better for fixed wings 

- ICM-45686 Module 6 Axis -- https://www.aliexpress.com/item/1005010560842695.html?spm=a2g0o.productlist.main.2.5c464222ltYQTf -- better for vibration heavy quads



## aircrafts

### quadcopter

- Angel30 3 inch Carbon Fiber Frame Kit Drone FPV -- https://www.aliexpress.com/item/1005009618459237.html?spm=a2g0o.order_list.order_list_main.180.6ba71802LI9kkS



### fixed wing

- Flying Bear Fx707s Aircraft -- https://www.aliexpress.com/item/1005007456726266.html?spm=a2g0o.order_list.order_list_main.464.6ba71802LI9kkS -- foamy converted to electric RC

- 50CM Big Foam Plane -- https://www.aliexpress.com/item/1005006154281634.html?spm=a2g0o.order_list.order_list_main.500.6ba71802LI9kkS -- foamy converted to electric RC

- EDGE540 EPP F3P -- https://item.taobao.com/item.htm?id=18053051397&mi_id=00003v-67AkjL1Cw3sGlAy4grqPOQZVp74xtqwATFfv0Z08 -- flat foamy



## arming pattern when creating new models or modifying existing models

- implement a safe 2-step arming for quadcopters matching DarwinFPV F415 AIO Flight Controller capabilities in accordance with FPV drone best practices.
- implement a safe 2-step arming for fixed wing aircraft that is not using/blocking channel 5.
- for each, ensure safe throttle cutoff 


## Flight Configurations

- for each drone model created, add these 3 flight configurations:
    - indoors: reduce all controls to minimal capability for gentle indoor flight (beginner level)
    - outdoors: reduce all controls to minimal capability for gentle outdoor flight (beginner level)
    - normal: no restriction on all controls (passthrought to betaflight configs)

- for each fixed wing model created, assume aircraft is equiped with Reflex V3 Flight Controller Gyro Stabilizer and add these 3 flight configuration modes:
    - Beginner
    - Advanced
    - Full Manual 


## EdgeTX Quick Tip: Change from Mode2 to Mode4 via a switch 

- for each model, generate the Mode2 to Mode4 change via a switch as discussed at  https://www.youtube.com/watch?v=kiKQy736huM&list=PLCwGMDApijb_nqDSc003n5U-ZyQgRojgE&index=7 . 


## synchronizing configurations

- Target: RadioMaster TX15 path (SD Card) = "d:\"
- Source: Git TX15 folder path (aka RC Transmitter Digital Twin) = @EdgeTX

-sync modes to implement:
    - SyncToRadio (update new but delete nothing)
    - SyncFromRadio (update new but delete nothing)
    - MirrorToRadio (update new and delete what is not in source)
    - MirrorFromRadio (update new and delete what is not in source)


## Folder/File location and naming conventions

- .cursor: @.cursor
- yaml configurations go into @EdgeTX folders as appropriate
- lua scripts go into @EdgeTX folders as appropriate
- Powershell scripts go into: @PowerShell  
- Python scripst go into:  @Python


## RC Digital Twin

- the RC Digital Twin is @EdgeTX
- the RC Physical Target is the SD Card accessible via = "d:\" (via USB when connection is established)


## Ask

- Ask for clarification to ensure intent is understood and is confirmed
