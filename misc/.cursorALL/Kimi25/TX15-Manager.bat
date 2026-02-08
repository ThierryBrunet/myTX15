@echo off
REM TX15 Configuration Helper
REM WBS: 02.02.01

echo ==========================================
echo RadioMaster TX15 Configuration Manager
echo ==========================================
echo.

:MENU
echo Select operation:
echo.
echo 1. Sync TO Radio (Git -^> SD Card)
echo 2. Sync FROM Radio (SD Card -^> Git)
echo 3. Mirror TO Radio (Destructive)
echo 4. Mirror FROM Radio (Destructive)
echo 5. Validate Models
echo 6. Create New Model
echo 7. Exit
echo.

set /p choice="Enter choice (1-7): "

if "%choice%"=="1" goto SYNCTORADIO
if "%choice%"=="2" goto SYNCFROMRADIO
if "%choice%"=="3" goto MIRRORTORADIO
if "%choice%"=="4" goto MIRRORFROMRADIO
if "%choice%"=="5" goto VALIDATE
if "%choice%"=="6" goto NEWMODE
if "%choice%"=="7" goto EXIT
goto MENU

:SYNCTORADIO
echo.
echo Syncing Git to Radio (Safe mode)...
PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\Sync-TX15Config.ps1" -Mode SyncToRadio -Verbose
pause
goto MENU

:SYNCFROMRADIO
echo.
echo Syncing Radio to Git (Safe mode)...
PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\Sync-TX15Config.ps1" -Mode SyncFromRadio -Verbose -CreateGitCommit
pause
goto MENU

:MIRRORTORADIO
echo.
echo WARNING: This will DELETE files on radio not in Git!
set /p confirm="Type MIRROR to confirm: "
if not "%confirm%"=="MIRROR" goto MENU
PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\Sync-TX15Config.ps1" -Mode MirrorToRadio -Force
pause
goto MENU

:MIRRORFROMRADIO
echo.
echo WARNING: This will DELETE files in Git not on radio!
set /p confirm="Type MIRROR to confirm: "
if not "%confirm%"=="MIRROR" goto MENU
PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\Sync-TX15Config.ps1" -Mode MirrorFromRadio -Force -CreateGitCommit
pause
goto MENU

:VALIDATE
echo.
echo Validating model files...
PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\Test-TX15Models.ps1"
pause
goto MENU

:NEWMODE
echo.
echo Create new model wizard
echo.
echo Select aircraft type:
echo 1. Quadcopter
echo 2. Fixed Wing
set /p typechoice="Type (1-2): "

if "%typechoice%"=="1" set MODELTYPE=Quad
if "%typechoice%"=="2" set MODELTYPE=FixedWing

set /p aircraft="Enter aircraft name (e.g., Angel30): "
set /p config="Enter config (Indoor/Outdoor/Normal or Beginner/Advanced/Manual): "

PowerShell -ExecutionPolicy Bypass -File "%~dp0scripts\New-TX15Model.ps1" -ModelType %MODELTYPE% -AircraftName "%aircraft%" -Config "%config%"
pause
goto MENU

:EXIT
echo.
echo Goodbye!
exit /b 0
