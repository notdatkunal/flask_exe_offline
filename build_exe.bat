@echo off
setlocal

REM Ensure we're in the script directory
cd /d %~dp0

REM Optional: activate venv if present
if exist .venv\Scripts\activate.bat (
  call .venv\Scripts\activate.bat
)

REM Install PyInstaller if missing
where pyinstaller >nul 2>nul
if errorlevel 1 (
  echo Installing PyInstaller...
  pip install pyinstaller
)

REM Build one-file executable
pyinstaller --onefile --name app app.py

REM Show output location
if exist dist\app.exe (
  echo.
  echo Build complete: %cd%\dist\app.exe
) else (
  echo Build failed. See logs above.
)

endlocal
exit /b 0
