# Cursor startup fix - run once in PowerShell, then restart Cursor
# Root cause: Git "dubious ownership" on OneDrive repos blocked the extension host

Write-Host "=== Cursor Startup Fix ===" -ForegroundColor Cyan

# 1. Ensure git trusts OneDrive project folders
$projectsRoot = "C:/Users/liuho/OneDrive - Embry-Riddle Aeronautical University/Documents/Work/Projects"
$repos = @(
    "$projectsRoot/agents",
    "$projectsRoot/kanban",
    $projectsRoot
)
foreach ($repo in $repos) {
    git config --global --add safe.directory $repo 2>$null
}
Write-Host "[OK] Git safe.directory entries added" -ForegroundColor Green

# 2. Kill stuck Cursor processes (safe to run before restart)
Get-Process -Name "Cursor" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Stopped any stuck Cursor processes" -ForegroundColor Green

# 3. Clear corrupted session restore / workspace cache (official workaround)
$pathsToClear = @(
    "$env:APPDATA\Cursor\Backups",
    "$env:APPDATA\Cursor\User\workspaceStorage\e80c13ec71fe2ccd0441767fe22db105",
    "$env:APPDATA\Cursor\Cache",
    "$env:APPDATA\Cursor\CachedData"
)
foreach ($p in $pathsToClear) {
    if (Test-Path $p) {
        Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
        Write-Host "[OK] Cleared: $p" -ForegroundColor Green
    }
}

# 4. Optional: fix folder ownership (run as admin if this fails)
$agentsPath = "$projectsRoot/agents"
if (Test-Path $agentsPath) {
    icacls $agentsPath /setowner "$env:USERDOMAIN\$env:USERNAME" /T /C 2>$null
    Write-Host "[OK] Attempted ownership fix on agents folder" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Now:" -ForegroundColor Yellow
Write-Host "  1. Start Cursor fresh (do NOT reopen previous windows)"
Write-Host "  2. File > Open Folder > select your agents project"
Write-Host "  3. After it works, you can set window.restoreWindows back to 'all' in settings"
