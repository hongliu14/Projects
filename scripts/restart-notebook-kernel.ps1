# Restart notebook environment - run from project root in PowerShell:
#   powershell -ExecutionPolicy Bypass -File scripts/restart-notebook-kernel.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

Write-Host "Stopping stuck Python processes..." -ForegroundColor Yellow
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Syncing environment (installs pypdf, gradio, etc.)..." -ForegroundColor Yellow
uv sync

$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
& $PythonExe -m ipykernel install --user --name=agents-venv --display-name="agents (.venv)"

Write-Host "Verifying imports for lab 3..." -ForegroundColor Yellow
& $PythonExe -c "from dotenv import load_dotenv; from openai import OpenAI; from pypdf import PdfReader; import gradio as gr; print('OK')"

Write-Host ""
Write-Host "Done. In Cursor:" -ForegroundColor Green
Write-Host "  1. Ctrl+Shift+P -> Developer: Reload Window"
Write-Host "  2. Open 1_foundations/3_lab3.ipynb"
Write-Host "  3. Select Kernel -> agents (.venv) or .venv (Python 3.12.x)"
Write-Host "  4. Kernel -> Restart Kernel"
Write-Host "  5. Run the first code cell with Shift+Enter"
