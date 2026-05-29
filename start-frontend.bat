@echo off
chcp 65001 >nul
echo ============================================
echo  [FRONTEND] Starting Vue on port 5173
echo ============================================
set PATH=C:\Program Files\nodejs;%PATH%
cd /d "%~dp0frontend"
npm run dev
