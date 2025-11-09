# Quick Setup Guide

## 1. Backend Setup (5 minutes)

### Install Dependencies
```bash
cd backend
npm install
```

### Configure Environment
Create/update `.env` file:
```env
MONGODB_URI=mongodb://localhost:27017/yathra-rekha
PORT=3000
JWT_SECRET=yathra-rekha-super-secret-key-2024
GOOGLE_CLIENT_ID=your-google-client-id-here
```

### Start MongoDB
- **Local MongoDB**: Start `mongod` service
- **MongoDB Atlas**: Use your Atlas connection string

### Start Backend Server
```bash
npm run dev
```
✅ Server should start at http://localhost:3000

## 2. Flutter Setup (3 minutes)

### Install Dependencies
```bash
cd ..
flutter pub get
```

### Run the App
```bash
flutter run
```

## 3. Test the Setup

### Test Backend API
Visit: http://localhost:3000
Should show: `{"message": "Yathra Rekha API Server"}`

### Test Flutter App
1. App should open with Malayalam welcome screen
2. Try username/password registration
3. Try login with created credentials

## 4. Google Sign-In Setup (Optional)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your client ID to `.env` file
6. For Android: Add SHA-1 fingerprint
7. For iOS: Add bundle identifier

## Troubleshooting

### Backend Issues
- **Port 3000 busy**: Change PORT in `.env`
- **MongoDB connection**: Check if MongoDB is running
- **Dependencies**: Run `npm install` again

### Flutter Issues
- **Dependencies**: Run `flutter pub get`
- **Build errors**: Run `flutter clean && flutter pub get`
- **Device not found**: Connect device or start emulator

### API Connection Issues
- Check backend is running on http://localhost:3000
- Update `baseUrl` in `lib/services/auth_service.dart` if needed
- For physical device: Use your computer's IP instead of localhost

## Quick Test Commands

```bash
# Test backend
curl http://localhost:3000

# Test registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456","name":"Test User"}'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456"}'
```