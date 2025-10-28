#!/usr/bin/env bash
set -Eeuo pipefail

# Ensure we run from the script directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Flags (defaults)
USE_SYSTEM=0
SKIP_INSTALL=0

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --use-system) USE_SYSTEM=1; shift ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Optional: activate venv if present (unless using system)
if [[ "$USE_SYSTEM" -eq 0 && -f .venv/bin/activate ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

# Install runtime dependencies (unless skipped)
if [[ "$SKIP_INSTALL" -eq 0 && -f requirements.txt ]]; then
  echo "Installing runtime dependencies..."
  pip install -r requirements.txt
else
  echo "Skipping dependency installation (--skip-install or no requirements.txt)"
fi

# Ensure PyInstaller is available
if ! command -v pyinstaller >/dev/null 2>&1; then
  if [[ "$SKIP_INSTALL" -eq 0 ]]; then
    echo "Installing PyInstaller..."
    pip install pyinstaller
  else
    echo "PyInstaller not found and --skip-install was set. Aborting." >&2
    exit 1
  fi
fi

# Detect current Python site-packages path (only needed when using system)
SITEPKG=""
if [[ "$USE_SYSTEM" -eq 1 ]]; then
  SITEPKG="$(python - <<'PY'
import site
get = getattr(site, 'getsitepackages', None)
print((get() or [site.getusersitepackages()])[0])
PY
)"
  if [[ -n "$SITEPKG" ]]; then
    echo "Using system site-packages: $SITEPKG"
  fi
fi

# Clean previous build artifacts
rm -rf build dist
rm -f app.spec

# Prepare optional --paths for PyInstaller
PYI_PATHS=()
if [[ "$USE_SYSTEM" -eq 1 && -n "$SITEPKG" ]]; then
  PYI_PATHS+=(--paths "$SITEPKG")
fi

# Build one-file executable (SFX-like)
pyinstaller --onefile --name app "${PYI_PATHS[@]}" \
  --hidden-import flask \
  --hidden-import jinja2 \
  --hidden-import werkzeug \
  app.py

# Show output location
if [[ -f dist/app.exe ]]; then
  OUT="dist/app.exe"
elif [[ -f dist/app ]]; then
  OUT="dist/app"
else
  echo "Build failed. See logs above." >&2
  exit 1
fi

echo
echo "Build complete: $(pwd)/$OUT"


