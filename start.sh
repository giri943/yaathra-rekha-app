#!/bin/bash

echo "Starting Yathra Rekha App..."
echo

echo "[1/3] Starting MongoDB..."
# Start MongoDB in background (adjust path as needed)
mongod --dbpath ./data &

echo "[2/3] Starting Backend Server..."
cd backend
npm run dev &
BACKEND_PID=$!

echo "[3/3] Starting Flutter App..."
cd ..
sleep 3
# Load environment variables and run Flutter
if [ -f .env ]; then
  export $(cat .env | xargs)
fi
flutter run -d chrome --web-port ${FLUTTER_WEB_PORT:-4000}

# Cleanup on exit
trap "kill $BACKEND_PID" EXIT