# PostgreSQL 資料庫初始化腳本 (Windows 直接安裝版)
$pgBin = "C:\Program Files\PostgreSQL\17\bin"
$env:PGPASSWORD = "esun_pass"

Write-Host "Creating user and database..." -ForegroundColor Cyan

# 建立使用者
& "$pgBin\psql.exe" -U postgres -h localhost -c "CREATE USER esun_user WITH PASSWORD 'esun_pass';" 2>&1
# 建立資料庫
& "$pgBin\psql.exe" -U postgres -h localhost -c "CREATE DATABASE esun_db OWNER esun_user;" 2>&1
# 賦予權限
& "$pgBin\psql.exe" -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE esun_db TO esun_user;" 2>&1

Write-Host "Running init SQL..." -ForegroundColor Cyan
& "$pgBin\psql.exe" -U postgres -h localhost -d esun_db -f "$PSScriptRoot\01-init.sql" 2>&1

Write-Host "Done!" -ForegroundColor Green
