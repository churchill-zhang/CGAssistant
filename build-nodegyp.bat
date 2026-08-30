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

cd CGANode
if not exist "node_modules\nan\nan.h" (
    echo CGANode\node_modules\nan is missing.
    exit /b 1
)
if not exist "node_modules\nan\nan_scriptorigin.h" (
    echo The vendored NAN 2.18.0 dependency is incomplete: nan_scriptorigin.h is missing.
    exit /b 1
)
if not exist "node_modules\nan\nan_define_own_property_helper.h" (
    echo The vendored NAN 2.18.0 dependency is incomplete: nan_define_own_property_helper.h is missing.
    exit /b 1
)

call node-gyp clean
if errorlevel 1 exit /b %errorlevel%

call node-gyp configure --target=20.11.1 --arch=ia32 --msvs_version=2022
if errorlevel 1 exit /b %errorlevel%

MSBuild.exe build\binding.sln /m /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v142 /p:WindowsTargetPlatformVersion=10.0.19041.0
if errorlevel 1 exit /b %errorlevel%

if not exist "build\Release\node_cga.node" (
    echo CGANode\build\Release\node_cga.node was not generated.
    exit /b 1
)

if not exist "..\build\Release" mkdir "..\build\Release"
copy /Y "build\Release\node_cga.node" "..\build\Release\node_cga.node" >nul
if errorlevel 1 exit /b %errorlevel%

endlocal
