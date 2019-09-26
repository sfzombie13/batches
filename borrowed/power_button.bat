echo off
SetLocal

openfiles > NUL 2>&1 
if %ERRORLEVEL% NEQ 0 (
    REM Command failed => no admin rights
    echo This executable requires admin-rights!
    exit /b 1
)

:: Get GUID of current power scheme
FOR /F "tokens=4" %%G IN ('powercfg /getactivescheme') DO set activeschemeGUID=%%G

:: Custom power scheme name
set custom_name=CUSTOM_POWER_SCHEME_STACK

:: Check if it already exists and if it exists, get its GUID
FOR /F "tokens=4" %%G IN ('powercfg -list ^| find "%custom_name%"') DO (
    REM custom power scheme with that name already exists
    set custom_GUID=%%G
    goto :SetCustomActive
)

:: Here we're sure it doesn't exist: copy current active scheme and get GUID of that copy
FOR /F "tokens=4" %%G IN ('powercfg -DUPLICATESCHEME %activeshcemeGUID%') DO et custom_GUID=%%G

:: change the name of the new scheme (the copy) to the custom name
powercfg -CHANGENAME %custom_GUID% %custom_name%

:SetCustomActive
powercfg -SETACTIVE %custom_GUID%
set activeschemeGUID=%custom_GUID%

:: Your code
POWERCFG /CHANGE monitor-timeout-ac 0
POWERCFG /CHANGE disk-timeout-ac 0
POWERCFG /CHANGE standby-timeout-ac 0
POWERCFG /CHANGE hibernate-timeout-ac 0

:: change the power button
powercfg -setacvalueindex %activeschemeGUID% SUB_BUTTONS PBUTTONACTION 000
powercfg -setdcvalueindex %activeschemeGUID% SUB_BUTTONS PBUTTONACTION 000

:: Change the start menu button (replace with powercfg method below if available)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_PowerButtonAction /t REG_DWORD /d 100
:: powercfg -setacvalueindex %activeschemeGUID% SUB_BUTTONS UIBUTTON_ACTION ???
:: powercfg -setdcvalueindex %activeschemeGUID% SUB_BUTTONS UIBUTTON_ACTION ???

EndLocal
exit /b 0

SHUTDOWN.exe /r /f /t 60 /d P:2:4