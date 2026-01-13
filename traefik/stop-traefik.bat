@echo off
echo Stopping Traefik Reverse Proxy...
cd /d D:\Boyong\traefik
docker-compose down
echo.
echo Traefik stopped.
pause
