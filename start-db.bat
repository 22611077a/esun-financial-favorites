@echo off
chcp 65001 >nul
echo ============================================
echo  [DB] Checking PostgreSQL service...
echo ============================================
sc query postgresql-17 | findstr "RUNNING" >nul 2>&1
if %errorlevel%==0 (
    echo  PostgreSQL is already running on localhost:5432
) else (
    echo  Starting PostgreSQL service...
    net start postgresql-17
)
echo.
echo  DB: esun_db  /  User: esun_user  /  Port: 5432
echo.
pause
