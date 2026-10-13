# ──────────────────────────────────────────────────────────────
# AI Goat -- Windows (PowerShell) port of scripts/start.sh
#
# Usage:  .\scripts\start.ps1           (from the AIGoat root)
#         .\scripts\start.ps1 -Fresh    (delete DB before start)
# ──────────────────────────────────────────────────────────────
param([switch]$Fresh)
$ErrorActionPreference = 'Stop'

$ProjectRoot  = Split-Path -Parent $PSScriptRoot
$PidDir       = Join-Path $ProjectRoot '.pids'
$LogDir       = Join-Path $ProjectRoot 'logs'
$DbFile       = Join-Path $ProjectRoot 'aigoat.db'
$ChromaDir    = Join-Path $ProjectRoot 'chroma_db'
$BackendPort  = if ($env:BACKEND_PORT)  { $env:BACKEND_PORT }  else { 8000 }
$FrontendPort = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 3000 }
$Ollama       = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
$env:PYTHONUTF8 = '1'

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Fail($m) { Write-Host "[FAIL]  $m" -ForegroundColor Red; exit 1 }

function Test-Url($url) {
    try { Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 5 | Out-Null; $true } catch { $false }
}
function Wait-Url($url, $label, $log, $tries) {
    for ($i = 0; $i -lt $tries; $i++) { if (Test-Url $url) { return }; Start-Sleep 1 }
    Warn "Last lines of ${log}:"; Get-Content $log -Tail 40 -ErrorAction SilentlyContinue
    Fail "$label did not answer at $url"
}
function Test-Port($port) {
    [bool](Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
}

if ($Fresh) {
    Info 'Fresh start requested -- removing existing database and vector store'
    Remove-Item $DbFile -Force -ErrorAction SilentlyContinue
    Remove-Item $ChromaDir -Recurse -Force -ErrorAction SilentlyContinue
    Ok 'Cleared database and ChromaDB'
}

New-Item -ItemType Directory -Force $PidDir, $LogDir | Out-Null
Set-Location $ProjectRoot

Write-Host "`n==========================================`n       AI Goat -- Starting Application    `n==========================================`n"

# ── Step 1: Python 3.11 virtual environment ───────────────────
if (-not (Test-Path 'venv')) {
    Info 'Creating Python 3.11 virtual environment...'
    py -3.11 -m venv venv
    if ($LASTEXITCODE -ne 0) { Fail 'Python 3.11 is required. Install it with: winget install Python.Python.3.11 --scope user' }
}
$Py = Join-Path $ProjectRoot 'venv\Scripts\python.exe'
$ver = & $Py -c "import sys; print('%d.%d' % sys.version_info[:2])"
if ($ver -ne '3.11') { Fail "venv is Python $ver; AIGoat pins 3.11. Delete venv\ and run again." }
Ok "Python $ver virtual environment"
Info 'Checking Python dependencies...'
& $Py -m pip install -q -r requirements.txt
Ok 'Python dependencies ready'

# ── Step 2: Ollama ─────────────────────────────────────────────
Info 'Checking Ollama...'
if (Test-Path $Ollama) {
    if (-not (Test-Url 'http://127.0.0.1:11434/api/version')) {
        Info 'Starting Ollama in the background...'
        $p = Start-Process $Ollama -ArgumentList 'serve' -WindowStyle Hidden -PassThru `
            -RedirectStandardError (Join-Path $LogDir 'ollama.log') -RedirectStandardOutput (Join-Path $LogDir 'ollama.out.log')
        $p.Id | Set-Content (Join-Path $PidDir 'ollama.pid')
        Start-Sleep 4
    }
    if (Test-Url 'http://127.0.0.1:11434/api/version') {
        Ok 'Ollama is running'
        $model = & $Py -c "import yaml; c=yaml.safe_load(open('config/config.yml')) or {}; print((c.get('ollama') or {}).get('model') or 'mistral')"
        $tags = (Invoke-RestMethod 'http://127.0.0.1:11434/api/tags').models.name
        if ($tags -match [regex]::Escape($model)) { Ok "Model '$model' is available" }
        else { Info "Pulling model '$model'..."; & $Ollama pull $model; Ok "Model '$model' pulled successfully" }
    } else { Warn 'Ollama did not start. AI chat features will be unavailable.' }
} else {
    Warn 'Ollama is not installed. Install it with: winget install Ollama.Ollama'
}

# ── Step 3-4: Database + seed ─────────────────────────────────
Info 'Applying database migrations...'
& $Py -m alembic upgrade head
Ok 'Database schema ready'
$needsSeed = & $Py -c @"
import asyncio
from app.core.database import async_session, init_db
from sqlalchemy import select, func
from app.models import User, Product
async def check():
    await init_db()
    async with async_session() as db:
        u = (await db.execute(select(func.count(User.id)))).scalar() or 0
        p = (await db.execute(select(func.count(Product.id)))).scalar() or 0
        print('yes' if u < 5 or p < 20 else 'no')
asyncio.run(check())
"@
if ($needsSeed -ne 'no') { Info 'Seeding demo data...'; & $Py -m scripts.seed; Ok 'Demo data seeded' }
else { Ok 'Database already has required data' }
& $Py -m scripts.seed --sync-support    | Out-Null; Ok 'Support tickets ready'
& $Py -m scripts.seed --sync-challenges | Out-Null; Ok 'Challenge metadata synced'

# ── Step 5: Backend ───────────────────────────────────────────
if (Test-Port $BackendPort) {
    if (Test-Url "http://127.0.0.1:$BackendPort/docs") { Warn "Port $BackendPort already in use and the API answers. Leaving it running." }
    else { Fail "Port $BackendPort is in use by another process." }
} else {
    Info "Starting backend on port $BackendPort..."
    $log = Join-Path $LogDir 'backend.log'
    $p = Start-Process $Py -ArgumentList '-m','uvicorn','app.main:app','--host','0.0.0.0','--port',$BackendPort,'--log-level','info' `
        -WorkingDirectory $ProjectRoot -WindowStyle Hidden -PassThru -RedirectStandardError $log -RedirectStandardOutput (Join-Path $LogDir 'backend.out.log')
    $p.Id | Set-Content (Join-Path $PidDir 'backend.pid')
    Wait-Url "http://127.0.0.1:$BackendPort/docs" 'Backend' $log 60
    Ok "Backend ready (PID: $($p.Id))"
}

# ── Step 6: Frontend ──────────────────────────────────────────
if (Test-Port $FrontendPort) {
    if (Test-Url "http://127.0.0.1:$FrontendPort/") { Warn "Port $FrontendPort already in use and the app answers. Leaving it running." }
    else { Fail "Port $FrontendPort is in use by another process." }
} else {
    Info "Starting frontend on port $FrontendPort..."
    $fe = Join-Path $ProjectRoot 'frontend'
    if (-not (Test-Path (Join-Path $fe 'node_modules'))) {
        Info 'Installing frontend dependencies (first run)...'
        Push-Location $fe; npm install --silent; Pop-Location
        Ok 'Frontend dependencies installed'
    }
    $env:PORT = $FrontendPort; $env:BROWSER = 'none'
    $log = Join-Path $LogDir 'frontend.log'
    $p = Start-Process 'cmd.exe' -ArgumentList '/c','npm','start' -WorkingDirectory $fe -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput $log -RedirectStandardError (Join-Path $LogDir 'frontend.err.log')
    $p.Id | Set-Content (Join-Path $PidDir 'frontend.pid')
    Wait-Url "http://127.0.0.1:$FrontendPort/" 'Frontend' $log 120
    Ok "Frontend ready (PID: $($p.Id))"
}

Write-Host "`n==========================================`n       AI Goat is running!                `n==========================================`n"
Write-Host "  Application:  http://localhost:$FrontendPort"
Write-Host "  API Docs:     http://localhost:$BackendPort/docs"
Write-Host "  Demo login:   alice / password123"
Write-Host "  Admin login:  admin / admin123"
Write-Host "  Stop:         .\scripts\stop.ps1   (add -Clean to delete the DB)`n"
