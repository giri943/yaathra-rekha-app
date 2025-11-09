@echo off
echo Starting Yathra Rekha App...
echo.

echo [1/3] Starting MongoDB...
start "MongoDB" cmd /k "mongod --dbpath data"

echo [2/3] Starting Backend Server...
cd backend
start "Backend" cmd /k "npm run dev"

echo [3/3] Starting Flutter App...
cd ..
timeout /t 3 /nobreak > nul
flutter run

pause