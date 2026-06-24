# Run once from the project root to fix Jupyter kernel connection in Cursor/VS Code.
# Usage:  powershell -ExecutionPolicy Bypass -File scripts/setup-notebook-kernel.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

Write-Host "=== Notebook kernel setup ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: uv is not installed. See setup/SETUP-PC.md" -ForegroundColor Red
    exit 1
}

Write-Host "`n[1/4] Installing dependencies (including ipykernel)..." -ForegroundColor Yellow
uv sync --group dev

$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    Write-Host "ERROR: Python not found at $PythonExe" -ForegroundColor Red
    exit 1
}
Write-Host "Python: $PythonExe" -ForegroundColor Green

Write-Host "`n[2/4] Verifying ipykernel..." -ForegroundColor Yellow
& $PythonExe -c "import ipykernel; print('ipykernel', ipykernel.__version__)"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n[3/4] Registering Jupyter kernel 'agents-venv'..." -ForegroundColor Yellow
& $PythonExe -m ipykernel install --user --name=agents-venv --display-name="agents (.venv)"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Fix bundled kernel.json to use absolute python path (avoids wrong interpreter on Windows)
$KernelJson = Join-Path $ProjectRoot ".venv\share\jupyter\kernels\python3\kernel.json"
if (Test-Path $KernelJson) {
    $pythonForJson = $PythonExe -replace '\\', '/'
    @"
{
 "argv": [
  "$pythonForJson",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "agents (.venv)",
 "language": "python",
 "metadata": {
  "debugger": true
 }
}
"@ | Set-Content -Path $KernelJson -Encoding UTF8
    Write-Host "Updated kernel.json with absolute Python path" -ForegroundColor Green
}

Write-Host "`n[4/4] Verifying lab imports..." -ForegroundColor Yellow
& $PythonExe -c "from dotenv import load_dotenv; from openai import OpenAI; from pypdf import PdfReader; import gradio as gr; print('All imports OK')"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "In Cursor:"
Write-Host "  1. Reload window (Ctrl+Shift+P -> Developer: Reload Window)"
Write-Host "  2. Open 1_foundations/3_lab3.ipynb"
Write-Host "  3. Click Select Kernel -> choose 'agents (.venv)' or '.venv (Python 3.12.x)'"
Write-Host "  4. Run the first code cell (imports) with Shift+Enter"
