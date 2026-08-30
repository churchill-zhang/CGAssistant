@echo off
setlocal
cd /d "%~dp0"

git submodule update --init --recursive
if errorlevel 1 exit /b %errorlevel%

if not exist "qhttp\3rdparty" mkdir "qhttp\3rdparty"
if not exist "qhttp\3rdparty\http-parser\.git" (
    git clone https://github.com/nodejs/http-parser.git "qhttp\3rdparty\http-parser"
    if errorlevel 1 exit /b %errorlevel%
)

endlocal
