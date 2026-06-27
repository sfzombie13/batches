@echo off
title Windows Cleanup
color 0A

echo.
echo ==========================================
echo Stopping update services...
echo ==========================================
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo.
echo ==========================================
echo Cleaning TEMP folders...
echo ==========================================
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1

del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo.
echo ==========================================
echo Cleaning Windows Update cache...
echo ==========================================
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1

echo.
echo ==========================================
echo Cleaning Delivery Optimization...
echo ==========================================
del /f /s /q "C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache\*" >nul 2>&1
for /d %%x in ("C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache\*") do rd /s /q "%%x" >nul 2>&1

echo.
echo ==========================================
echo Cleaning Prefetch...
echo ==========================================
del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1

echo.
echo ==========================================
echo Cleaning DirectX shader cache...
echo ==========================================
del /f /s /q "%LOCALAPPDATA%\D3DSCache\*" >nul 2>&1

echo.
echo ==========================================
echo Cleaning WER reports...
echo ==========================================
rd /s /q "C:\ProgramData\Microsoft\Windows\WER" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER" >nul 2>&1

echo.
echo ==========================================
echo Cleaning thumbnail cache...
echo ==========================================
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*" >nul 2>&1

echo.
echo ==========================================
echo Cleaning crash dumps...
echo ==========================================
del /f /s /q "C:\Windows\Minidump\*" >nul 2>&1
del /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1

echo.
echo ==========================================
echo Running DISM cleanup...
echo ==========================================
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

echo.
echo ==========================================
echo Restarting services...
echo ==========================================
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo.
echo ==========================================
echo Cleanup complete.
echo ==========================================
pause