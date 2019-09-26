@ECHO OFF
:: Check Windows version and command line argument (none allowed)
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
IF NOT  "%~2"==""           GOTO Syntax

SETLOCAL ENABLEDELAYEDEXPANSION

:: Display head to Standard Error, so it may be separated from the actual results
1>&2 ECHO.
1>&2 ECHO .NET Framework versions installed on this computer:
1>&2 ECHO.

:: Use prefixes if both 32 and 64 bit versions exist
IF EXIST %windir%\Microsoft.NET\Framework64 (
	SET b32=	[32bit]  
	SET b64=	[64bit]  
) ELSE (
	SET b32=
	SET b64=
)

:: List all 32 bit versions
FOR /D %%A IN (%windir%\Microsoft.NET\Framework\*) DO (
	SET NETFx=%%~nxA
	ECHO %b32%	!NETFx:v=!
)

:: List all 64 bit versions if any exists
IF EXIST %windir%\Microsoft.NET\Framework64 (
	ECHO.
	FOR /D %%A IN (%windir%\Microsoft.NET\Framework64\*) DO (
		SET NETFx=%%~nxA
		ECHO %b64%	!NETFx:v=!
	)
)

:: Check if a specified version is installed
IF NOT "%~1"=="" (
	SET OK=1
	IF EXIST %windir%\Microsoft.NET\Framework\v%1.* (
		SET OK=0
	)
	IF EXIST %windir%\Microsoft.NET\Framework64\v%1.* (
		SET OK=0
	)
)

ENDLOCAL & EXIT /B %OK%


:Syntax
ECHO NETFxVer.bat,  Version 3.00 for Windows 2000 or later
ECHO List installed .NET Framework versions, or check if specified one is installed
ECHO.
ECHO Usage:    NETFXVER.BAT  [ n.n ]
ECHO.
ECHO Where:    n.n   is the version to be checked, e.g. 3.5
ECHO.
ECHO Returns:  A list of all installed versions is displayed on screen.
ECHO           If a version to be checked was specified, the return code
ECHO           (ERRORLEVEL) will be 0 if it is installed, or 1 if not.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
