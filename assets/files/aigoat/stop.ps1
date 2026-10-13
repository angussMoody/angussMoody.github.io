# ──────────────────────────────────────────────────────────────
# AI Goat -- Windows (PowerShell) port of scripts/stop.sh
#
# Usage:  .\scripts\stop.ps1          (stop all services)
#         .\scripts\stop.ps1 -Clean   (stop + delete database for fresh start)
# ──────────────────────────────────────────────────────────────
param([switch]$Clean)

$ProjectRoot  = Split-Path -Parent $PSScriptRoot
$PidDir       = Join-Path $ProjectRoot '.pids'
$BackendPort  = if ($env:BACKEND_PORT)  { $env:BACKEND_PORT }  else { 8000 }
$FrontendPort = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 3000 }

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }

Write-Host "`n==========================================`n       AI Goat -- Stopping Application    `n==========================================`n"

function Stop-Service-ByPid($name) {
    $file = Join-Path $PidDir "$name.pid"
    if (Test-Path $file) {
        $id = Get-Content $file
        if (Get-Process -Id $id -ErrorAction SilentlyContinue) {
            Info "Stopping $name (PID: $id)..."
            # /T also kills the child processes (npm -> node, uvicorn workers)
            taskkill /PID $id /T /F | Out-Null
            Ok "$name stopped"
        } else { Info "$name (PID: $id) is not running" }
        Remove-Item $file -Force
    } else { Info "No PID file for $name" }
}

function Clear-Port($port) {
    Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique |
        ForEach-Object { Info "Cleaning up PID $_ on port $port..."; taskkill /PID $_ /T /F | Out-Null }
}

Stop-Service-ByPid 'frontend'; Clear-Port $FrontendPort
Stop-Service-ByPid 'backend';  Clear-Port $BackendPort
Stop-Service-ByPid 'ollama'

if ($Clean) {
    Info 'Cleaning database and vector store...'
    Remove-Item (Join-Path $ProjectRoot 'aigoat.db') -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $ProjectRoot 'chroma_db'), (Join-Path $ProjectRoot 'logs') -Recurse -Force -ErrorAction SilentlyContinue
    Ok 'Removed: aigoat.db, chroma_db/, logs/'
}

Remove-Item $PidDir -Recurse -Force -ErrorAction SilentlyContinue
Ok "AI Goat stopped.`n"
