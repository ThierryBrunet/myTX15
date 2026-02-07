I'd like to configure my RC radio and aircraft models via Cursor. Generate related instructions/rules (i.e. .md files ) that may be added to the .cursor folder and generate related tools/utilitiees in PowerShell or Python, whichever is more suited for the task, in accordance with below directives:


## Tools/Utilities/Workflows

- Powershell prefered is Python provide same outcome.
- adopt the WBS pattern with xx.yy.zz numbering for high-level phase, sub-steps and detailled steps (xx,yy,zz each starting from 01).


## Transmitter

- RC radio = RadioMaster TX15.


## Receivers

- receiver hardware 1 = AliExpress ELRS 2.4Ghz PWM 7CH CRSF Receiver (AKA Cyclone) -- https://www.aliexpress.com/item/1005007033545569.html?spm=a2g0o.order_list.order_list_main.27.41aa1802kgOMzU .

- receiver hardware 2 = HPXGRC 2.4G ExpressLRS ELRS Receiver -- https://www.aliexpress.com/item/1005009645506956.html?spm=a2g0o.order_list.order_list_main.22.41aa1802kgOMzU .

- receiver hardware 3 = DarwinFPV F415 AIO Flight Controller F4 2.4G ExpressLRS FC 4In1 ESC -- https://www.aliexpress.com/item/1005009990173646.html?spm=a2g0o.order_list.order_list_main.11.41aa1802kgOMzU .

- for the Cyclone receiver, note the configuration files for PWM 7CH (7CH.json) or CRSF (CRSF.json).


## Open Source Software on GitHub

- EdgeTX version = Latest non-RC version for TX15.
- ELRS version = Latest non-RC version.
- ExpressLRS Companion = Latest non-RC version.


## arming pattern when creating new models or modifying existing models

- implement a safe 2-step arming for quadcopters matching DarwinFPV F415 AIO Flight Controller capabilities in accordance with FPV drone best practices.
- implement a safe 2-step arming for fixed wing aircraft that is not using/blocking channel 5.



## EdgeTX Quick Tip: Change from Mode2 to Mode4 via a switch 

- for each model, generate the Mode2 to Mode4 change via a switch as discussed at  https://www.youtube.com/watch?v=kiKQy736huM&list=PLCwGMDApijb_nqDSc003n5U-ZyQgRojgE&index=7 . 


## synchronizing configurations

- generate skill .md files for synchronizing TX15 RadioMaster Transmitter code/configurations (i.e. SD card path) and related git repo opened with AI IDE/CLI (e.g. Cursor / VSCode / Claude CLI / Grok Build)
- RadioMaster TX15 path (SD Card) = "d:\"
- Git TX15 folder path = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster_TX15\myTX15\EdgeTX"




## cursor instructions downlaod

- package all rules/instructions/skills .md files into a single zip file reay to download.


