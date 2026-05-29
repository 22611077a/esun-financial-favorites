@echo off
chcp 65001 >nul
echo ============================================
echo  [BACKEND] Starting Spring Boot on port 8080
echo ============================================
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot
set PATH=%JAVA_HOME%\bin;C:\Users\asus\tools\maven\apache-maven-3.9.6\bin;%PATH%
cd /d "%~dp0backend"
mvn spring-boot:run
