echo off
cls
:--------------------------------------
:menu
cls
ECHO.
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO What would you like to do? Type 4 to exit.
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO.
ECHO 1 - Clear the print spooler
ECHO 2 - Restore network connectivity
ECHO 3 - Get computer information
ECHO 4 - Exit
ECHO.

SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO print
IF %M%==2 GOTO network
IF %M%==3 GOTO compinfo
IF %M%==4 GOTO EOF

:print
:: check if we are admin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"

@echo off
net stop spooler 
pause
cd c:\windows\system32\spool\printers 
pause
whoami
echo %cd%
pause
::del /Q *.* 
pause
net start spooler
goto menu

:network
:: check if we are admin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"

@echo off
ipconfig /release
ipconfig /renew
ipconfig /flushdns
ipconfig /registerdns
netsh dump
nbtstat -R
netsh int ip reset reset.log
netsh winsock reset
echo You need to restart now to finish configuration changes..
::set /p answer=Restart now?
::if %answer%="y" shutdown /r /t 0 else
::if %answer%="yes" shutdown /r /t 0 else
pause
goto menu

:compinfo
@echo off
REM set variables
set computer=
set system=
set manufacturer=
set model=
set serialnumber=
set osname=
set sp=
set cstring=
set ustring=
set pstring=

FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS Get csname /value') do SET computer=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS Get csname /value') do SET system=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Model /value') do SET model=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% Bios Get SerialNumber /value') do SET serialnumber=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% os get ServicePackMajorVersion /value') do SET sp=%%A

echo done!

echo ----------------
echo System Name: %system%
echo Manufacturer: %manufacturer%
echo Model: %model%
echo Serial Number: %serialnumber%
echo Operating System: %osname%
echo Service Pack: %sp%
echo ----------------

REM Generate file
SET file="%~dp0%computer%.txt"
echo ---------------- > %file%
echo Details For %computer%: >> %file%
echo System Name: %system% >> %file%
echo Manufacturer: %manufacturer% >> %file%
echo Model: %model% >> %file%
echo Serial Number: %serialnumber% >> %file%
echo Operating System: %osname% >> %file%
echo Service Pack: %sp% >> %file%
echo ---------------- >> %file%

echo File created at %file%


REM request user to push any key to continue
pause
goto menu