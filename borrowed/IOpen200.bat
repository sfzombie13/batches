@if (@X)==(@Y) @end /* JScript comment
@echo off

    cscript //E:JScript //nologo "%~f0" 

exit /b %errorlevel%
@if (@X)==(@Y) @end JScript comment */


var WshShell = new ActiveXObject("WScript.Shell");
WshShell.Run("control inetcpl.cpl");
WshShell.AppActivate("Internet Properties");

WScript.Sleep(200);
WshShell.SendKeys("+{TAB}");
WScript.Sleep(200);

WScript.Echo("RIGHT keys.....");
WshShell.SendKeys("{RIGHT}");
WScript.Sleep(200);
WshShell.SendKeys("{RIGHT}");
WScript.Sleep(200);
WshShell.SendKeys("{RIGHT}");
WScript.Sleep(200);
WshShell.SendKeys("{RIGHT}");
WScript.Sleep(200);
//WshShell.SendKeys("{RIGHT}");

WshShell.SendKeys("{TAB}");
WScript.Sleep(200);
WshShell.SendKeys("{TAB}");
WScript.Sleep(200);
WshShell.SendKeys("{TAB}");
WScript.Sleep(200);
WshShell.SendKeys("{TAB}");
WScript.Sleep(200);
WshShell.SendKeys("{TAB}");
WScript.Sleep(200);
WshShell.SendKeys("{ENTER}");
WScript.Sleep(200);
