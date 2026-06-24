# Double-click this file or run in Admin PowerShell:
#   powershell -ExecutionPolicy Bypass -File "G:\My Drive\Projects\agents\scripts\install-pypdf.ps1"

$ErrorActionPreference = "Continue"
$LogFile = Join-Path $env:TEMP "agents-install-pypdf.log"
$ProjectRoot = "G:\My Drive\Projects\agents"
$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"

function Log($msg) {
    $line = "$(Get-Date -Format 'HH:mm:ss') $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

Log "=== install-pypdf.ps1 ==="
Log "Log file: $LogFile"
Set-Location $ProjectRoot

if (Get-Command uv -ErrorAction SilentlyContinue) {
    Log "Running: uv sync"
    uv sync 2>&1 | ForEach-Object { Log $_ }
} else {
    Log "WARNING: uv not in PATH"
}

if (Test-Path $PythonExe) {
    Log "Running: pip install pypdf gradio"
    & $PythonExe -m pip install pypdf gradio 2>&1 | ForEach-Object { Log $_ }

    Log "Verifying PdfReader import..."
    & $PythonExe -c "from pypdf import PdfReader; print('PdfReader OK')" 2>&1 | ForEach-Object { Log $_ }
    if ($LASTEXITCODE -eq 0) {
        Log "SUCCESS"
    } else {
        Log "FAILED - check $LogFile"
    }
} else {
    Log "ERROR: Python not found at $PythonExe"
    Log "Run 'uv sync' from project root first."
}

Log "Done."
Read-Host "Press Enter to close"
