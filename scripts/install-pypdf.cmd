@echo off
cd /d "G:\My Drive\Projects\agents"
echo Installing pypdf (PdfReader) into project .venv...
uv sync
if errorlevel 1 (
    echo uv sync failed. Trying pip directly...
    ".venv\Scripts\python.exe" -m pip install pypdf gradio
)
".venv\Scripts\python.exe" -c "from pypdf import PdfReader; print('PdfReader OK')"
if errorlevel 1 (
    echo INSTALL FAILED - see errors above
    pause
    exit /b 1
)
echo.
echo SUCCESS. Restart your notebook kernel in Cursor, then re-run the first code cell.
pause
