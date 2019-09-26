@echo off

if %username%\Desktop\comp_info not exist mkdir %username%\Desktop\comp_info

copy check_dotnet_vers.bat %username%\Desktop\comp_info

copy key_extract_write.vbs %username%\Desktop\comp_info

copy test_comp_info_apps.bat %username%\Desktop\comp_info

copy run.bat %username%\Desktop\comp_info

run.bat


