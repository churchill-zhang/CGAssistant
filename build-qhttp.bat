@echo off
setlocal
cd /d "%~dp0"

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" set "VSWHERE=vswhere.exe"

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "InstallDir=%%i"
if not defined InstallDir (
    echo Visual Studio with C++ tools was not found.
    exit /b 1
)

call "%InstallDir%\Common7\Tools\vsdevcmd.bat" -arch=x86 -host_arch=x86 -vcvars_ver=14.29 -winsdk=10.0.19041.0
if errorlevel 1 exit /b %errorlevel%

cd qhttp
qmake qhttp.pro -spec win32-msvc "CONFIG+=qtquickcompiler release"
if errorlevel 1 exit /b %errorlevel%

jom -f Makefile qmake_all
if errorlevel 1 exit /b %errorlevel%

jom
if errorlevel 1 exit /b %errorlevel%

if not exist "xbin\qhttp.dll" (
    echo qhttp\xbin\qhttp.dll was not generated.
    exit /b 1
)

if not exist "..\build" mkdir "..\build"
copy /Y "xbin\qhttp.dll" "..\build\qhttp.dll" >nul
if errorlevel 1 exit /b %errorlevel%

endlocal
