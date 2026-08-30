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

cd boost
if not exist b2.exe (
    call bootstrap.bat vc142
    if errorlevel 1 exit /b %errorlevel%
)

b2.exe headers
if errorlevel 1 exit /b %errorlevel%

b2.exe -j%NUMBER_OF_PROCESSORS% --toolset=msvc-14.2 address-model=32 variant=release --with-date_time --with-thread --with-container --with-system --with-locale --with-serialization --with-regex --stagedir="stage" link=static runtime-link=shared stage
if errorlevel 1 exit /b %errorlevel%

b2.exe -j%NUMBER_OF_PROCESSORS% --toolset=msvc-14.2 address-model=32 variant=release --with-date_time --with-thread --with-container --with-system --with-locale --with-serialization --with-regex --stagedir="stage" link=static runtime-link=static stage
if errorlevel 1 exit /b %errorlevel%

endlocal
