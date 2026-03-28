@echo off
chcp 65001 >nul
echo ==================================
echo NAS Material Manager v3
echo ==================================
echo.

cd /d "%~dp0backend"

if not exist ".env" (
    echo Creating .env file from .env.example...
    copy .env.example .env
    echo Please edit .env file to configure your settings
    echo.
)

echo Installing dependencies...
call npm install

echo.
echo Starting server...
echo The server will be available at http://localhost:3000
echo.
echo Default admin credentials:
echo   Username: admin
echo   Password: admin123
echo.
echo IMPORTANT: Please change the admin password after first login!
echo.

call npm start
