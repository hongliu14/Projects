# Run as Administrator: right-click -> "Run with PowerShell" or open Admin PowerShell and run:
#   powershell -ExecutionPolicy Bypass -File "G:\My Drive\Projects\agents\scripts\install-packages-admin.ps1"

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Re-launching as Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $ProjectRoot

Write-Host "=== Installing packages with uv (Admin) ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: uv not found. Install from https://docs.astral.sh/uv/" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

uv sync
uv run python -c "from pypdf import PdfReader; print('PdfReader OK')"
uv run python -c "import gradio; print('gradio OK')"

Write-Host ""
Write-Host "Done. Restart your notebook kernel in Cursor, then re-run the import cell." -ForegroundColor Green
Read-Host "Press Enter to exit"
