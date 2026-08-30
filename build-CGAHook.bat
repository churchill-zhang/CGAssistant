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

MSBuild.exe CGAssistant.sln /t:CGAHook /m /p:Configuration=Release /p:Platform="x86" /p:PlatformToolset=v142 /p:WindowsTargetPlatformVersion=10.0.19041.0
if errorlevel 1 exit /b %errorlevel%

if not exist "build\CGAHook.dll" (
    echo build\CGAHook.dll was not generated.
    exit /b 1
)

endlocal
