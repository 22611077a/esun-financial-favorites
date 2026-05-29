# E.SUN Financial Favorites System - Launcher
$Host.UI.RawUI.WindowTitle = "E.SUN Launcher"
$root = $PSScriptRoot   # the folder this script lives in

function Write-Step($n, $msg) {
    Write-Host ""
    Write-Host "  [$n] $msg" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  =============================================" -ForegroundColor DarkBlue
Write-Host "   E.SUN Bank - Financial Favorites System" -ForegroundColor White
Write-Host "  =============================================" -ForegroundColor DarkBlue

# ── 1. Kill old backend ───────────────────────────────────────
Write-Step "1/4" "Checking port 8080..."
$listening = netstat -ano | Select-String ":8080\s+.*LISTENING"
if ($listening) {
    $oldPid = (($listening | Select-Object -First 1) -split '\s+')[-1].Trim()
    Write-Host "        Port 8080 occupied (PID $oldPid), stopping..." -ForegroundColor Yellow
    Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}
Write-Host "        OK - port 8080 is free." -ForegroundColor Green

# ── 2. Start Backend ─────────────────────────────────────────
Write-Step "2/4" "Starting Backend (Spring Boot : 8080)..."
$backendBat = Join-Path $root "start-backend.bat"
Start-Process -FilePath "cmd.exe" -ArgumentList "/k `"$backendBat`"" -WindowStyle Minimized
Write-Host "        Backend window started (minimized in taskbar)." -ForegroundColor Green

# ── 3. Start Frontend ────────────────────────────────────────
Write-Step "3/4" "Starting Frontend (Vue + Vite : 5173)..."
$frontendBat = Join-Path $root "start-frontend.bat"
Start-Process -FilePath "cmd.exe" -ArgumentList "/k `"$frontendBat`"" -WindowStyle Minimized
Write-Host "        Frontend window started (minimized in taskbar)." -ForegroundColor Green

# ── 4. Wait for backend then open browser ───────────────────
Write-Step "4/4" "Waiting for services to be ready (up to 90s)..."
Write-Host ""

$elapsed = 0
$ready   = $false
while ($elapsed -lt 90) {
    Start-Sleep -Seconds 3
    $elapsed += 3
    $up = netstat -ano | Select-String ":8080\s+.*LISTENING"
    if ($up) { $ready = $true; break }
    Write-Host "        Still waiting... ($elapsed`s)" -ForegroundColor DarkGray
}

Write-Host ""
if ($ready) {
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host "   All services are ready!" -ForegroundColor Green
    Write-Host "  =============================================" -ForegroundColor Green
} else {
    Write-Host "  [!] Backend is taking longer than expected." -ForegroundColor Yellow
    Write-Host "      Opening browser anyway - refresh if page is blank." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "   Backend  -->  http://localhost:8080" -ForegroundColor White
Write-Host "   Frontend -->  http://localhost:5173" -ForegroundColor White
Write-Host ""
Start-Sleep -Seconds 2
Start-Process "http://localhost:5173"
Write-Host "  Browser opened!" -ForegroundColor Green
Write-Host ""
Write-Host "  To STOP: close this window AND the two minimized" -ForegroundColor DarkGray
Write-Host "  windows (Backend / Frontend) in the taskbar." -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit this launcher"
