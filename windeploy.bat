@echo off
setlocal
cd /d "%~dp0"

if not exist "build\CGAssistant.exe" (
    echo build\CGAssistant.exe does not exist.
    exit /b 1
)

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" set "VSWHERE=vswhere.exe"

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "InstallDir=%%i"
if not defined InstallDir (
    echo Visual Studio with C++ tools was not found.
    exit /b 1
)

call "%InstallDir%\Common7\Tools\vsdevcmd.bat" -arch=x86 -host_arch=x86 -vcvars_ver=14.29 -winsdk=10.0.19041.0
if errorlevel 1 exit /b %errorlevel%

windeployqt --release --no-compiler-runtime "build\CGAssistant.exe"
if errorlevel 1 exit /b %errorlevel%

set "VCRedistDir=%InstallDir%\VC\Redist\MSVC\14.29.30133\x86\Microsoft.VC142.CRT"
if not exist "%VCRedistDir%\vcruntime140.dll" (
    echo The x86 VC142 runtime was not found at %VCRedistDir%.
    exit /b 1
)

copy /Y "%VCRedistDir%\*.dll" "build\" >nul
if errorlevel 1 exit /b %errorlevel%

endlocal
