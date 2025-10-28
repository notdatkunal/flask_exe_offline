# Flask Sample Server

A minimal Flask server with a few sample APIs and a Windows build script to create a standalone .exe.

## Requirements
- Python 3.x installed and on PATH
- Optional: virtual environment (recommended)

## Setup & Run (dev)
1. Open a terminal in this folder.
2. (Optional) Create and activate a venv:
   - `python -m venv .venv`
   - `.venv\Scripts\activate`
3. Install deps:
   - `pip install -r requirements.txt`
4. Start the server:
   - `python app.py`

Server runs at `http://127.0.0.1:5000`.

## Build Windows Executable
Use the provided script to build a one-file .exe with PyInstaller.

- Standard build (installs deps, uses venv if present):
  - `build_exe.bat`

- Use system-installed Python/Flask and skip installs:
  - `build_exe.bat --use-system --skip-install`
  - Make sure `python -c "import flask"` works in your current shell.

Output is at `dist\app.exe`.

## API Endpoints
- `GET /` → `{ "message": "Flask server is running" }`
- `GET /health` → `{ "status": "ok" }`
- `GET /echo/<value>` → `{ "echo": "<value>" }`
- `POST /sum` with JSON `{ "numbers": [1,2,3.5] }` → `{ "sum": 6.5 }`

## curl Examples
```bash
curl http://127.0.0.1:5000/
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/echo/hello
curl -X POST http://127.0.0.1:5000/sum -H "Content-Type: application/json" -d "{\"numbers\":[1,2,3]}"
```

## Notes
- To stop the server: Ctrl+C in the terminal.
- If Windows Defender blocks the exe: More info → Run anyway.
- To change exe name/icon, edit `build_exe.bat` (e.g., `--name` and `--icon path.ico`).
