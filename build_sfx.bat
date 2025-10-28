@echo off
setlocal

REM Ensure we're in the script directory
cd /d %~dp0

REM Flags (defaults)
set "USE_SYSTEM=0"
set "SKIP_INSTALL=0"

REM Parse args
for %%A in (%*) do (
  if /I "%%~A"=="--use-system" set "USE_SYSTEM=1"
  if /I "%%~A"=="--skip-install" set "SKIP_INSTALL=1"
)

REM Optional: activate venv if present (unless using system)
if "%USE_SYSTEM%"=="0" if exist .venv\Scripts\activate.bat (
  call .venv\Scripts\activate.bat
)

REM Prefer offline wheels in deps/ if present
set "DEPS_DIR=%cd%\deps"
set "HAS_DEPS=0"
if exist "%DEPS_DIR%" (
  for /f %%i in ('dir /b "%DEPS_DIR%\*.whl" 2^>nul ^| find /c /v ""') do set "WHEEL_COUNT=%%i"
  if not "%WHEEL_COUNT%"=="0" set "HAS_DEPS=1"
)

REM Install runtime dependencies (unless skipped)
if "%SKIP_INSTALL%"=="0" (
  if exist requirements.txt (
    echo Installing runtime dependencies...
    if "%HAS_DEPS%"=="1" (
      echo Using local wheels in deps\ for offline install
      pip install --no-index --find-links "%DEPS_DIR%" -r requirements.txt
    ) else (
      pip install -r requirements.txt
    )
  ) else (
    echo No requirements.txt found; skipping dependency install
  )
) else (
  echo Skipping dependency installation (--skip-install)
)

REM Ensure PyInstaller is available
where pyinstaller >nul 2>nul
if errorlevel 1 (
  if "%SKIP_INSTALL%"=="0" (
    if "%HAS_DEPS%"=="1" (
      echo Installing PyInstaller from local deps...
      pip install --no-index --find-links "%DEPS_DIR%" pyinstaller pyinstaller-hooks-contrib
    ) else (
      echo Installing PyInstaller from PyPI...
      pip install pyinstaller
    )
  ) else (
    echo PyInstaller not found and --skip-install was set. Aborting.
    exit /b 1
  )
)

REM Detect current Python site-packages path (only needed when using system)
set "SITEPKG="
if "%USE_SYSTEM%"=="1" (
  for /f "usebackq delims=" %%i in (`python -c "import site; p=getattr(site,'getsitepackages',None); print((p() or [site.getusersitepackages()])[0])"`) do set "SITEPKG=%%i"
  if defined SITEPKG echo Using system site-packages: %SITEPKG%
)

REM Clean previous build artifacts
if exist build (
  rmdir /s /q build
)
if exist dist (
  rmdir /s /q dist
)
if exist app.spec (
  del /q app.spec
)

REM Prepare optional --paths for PyInstaller
set "PYI_PATHS="
if "%USE_SYSTEM%"=="1" if defined SITEPKG (
  set "PYI_PATHS=--paths \"%SITEPKG%\""
)

REM Build one-file self-extracting executable
pyinstaller --onefile --name app %PYI_PATHS% ^
  --hidden-import flask ^
  --hidden-import jinja2 ^
  --hidden-import werkzeug ^
  app.py

REM Show output location
if exist dist\app.exe (
  echo.
  echo Build complete: %cd%\dist\app.exe
) else (
  echo Build failed. See logs above.
  exit /b 1
)

endlocal
exit /b 0

