@echo off
echo Starting Traefik Reverse Proxy...
cd /d D:\Boyong\traefik
docker-compose up -d
echo.
echo Traefik is starting...
echo.
echo Checking status...
timeout /t 3 >nul
docker-compose ps
echo.
echo Access points:
echo - Pareng Boyong: https://win-ai.innovatehub.site
echo - Traefik Dashboard: http://localhost:9090
echo.
pause
