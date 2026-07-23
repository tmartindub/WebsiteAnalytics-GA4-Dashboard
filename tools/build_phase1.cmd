@echo off
setlocal

call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
if errorlevel 1 exit /b 1

msbuild "WebsiteAnalytics.dproj" /target:Build /property:Config=Debug /property:Platform=Win32 /verbosity:minimal
if errorlevel 1 exit /b 1
copy /Y "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\sqlite3.dll" "bin\Win32\Debug\sqlite3.dll" >nul
if errorlevel 1 exit /b 1

msbuild "WebsiteAnalytics.dproj" /target:Build /property:Config=Debug /property:Platform=Win64 /verbosity:minimal
if errorlevel 1 exit /b 1
copy /Y "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin64\sqlite3.dll" "bin\Win64\Debug\sqlite3.dll" >nul
if errorlevel 1 exit /b 1

echo PHASE1_BUILD_OK
exit /b 0
