@echo off

REM Change to the directory of the script to ensure relative paths work
cd /d "%~dp0"

REM Start the backend server
echo Starting backend...
cd backend
start "" /min main.exe

REM Return to the root directory and wait for the backend to be ready
cd ..
echo Waiting for backend to be ready...
:loop
timeout /t 1 >nul
curl http://127.0.0.1:8000 >nul 2>&1
if %errorlevel% neq 0 (
    goto loop
)

REM Start the Electron web app
echo Backend is ready. Starting web app...
cd webapp
start "" my-electron-app.exe

REM Monitor the Electron app process
echo Monitoring Electron app. Close the Electron app to shut down the backend...
:monitor
timeout /t 1 >nul
tasklist /FI "IMAGENAME eq my-electron-app.exe" 2>NUL | find /I "my-electron-app.exe" >NUL
if %errorlevel% neq 0 (
    echo Electron app closed. Shutting down backend...
    taskkill /IM main.exe /F
    goto end
)
goto monitor

:end
echo All processes stopped. Exiting script.
exit
