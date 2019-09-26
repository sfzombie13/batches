@echo off

call check_dotnet_vers.bat 

call key_extract_write.vbs

call test_comp_info_apps.bat

