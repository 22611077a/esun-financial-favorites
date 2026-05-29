@echo off
chcp 65001 >nul
echo ============================================
echo  [DB] Starting PostgreSQL container...
echo ============================================
cd /d "%~dp0docker"
docker compose up -d
echo.
echo Done! PostgreSQL is running on localhost:5432
echo DB: esun_db  User: esun_user
pause
