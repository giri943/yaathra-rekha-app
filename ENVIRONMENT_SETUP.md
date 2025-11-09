# Environment Setup

## Backend Environment Variables

Copy `backend/.env.example` to `backend/.env` and update the values:

```bash
cp backend/.env.example backend/.env
```

Required variables:
- `MONGODB_URI`: MongoDB connection string
- `PORT`: Backend server port (default: 3000)
- `JWT_SECRET`: Secret key for JWT tokens (change in production)
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `NODE_ENV`: Environment (development/production)

## Flutter Environment Variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

Required variables:
- `API_BASE_URL`: Backend API URL
- `FLUTTER_WEB_PORT`: Flutter web development port

## Running with Environment Variables

### Backend
```bash
cd backend
npm run dev
```

### Flutter
```bash
flutter run -d chrome --web-port 4000 --dart-define=API_BASE_URL=http://localhost:3000/api
```

### Using Start Script
```bash
./start.sh
```

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API and People API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `http://localhost:4000`
   - `http://localhost:4000/auth/callback`
6. Copy the client ID to your `.env` files