# യാത്ര രേഖ (Yathra Rekha) - Vehicle Management App

A Malayalam-language mobile application for managing contract carriers and vehicle business operations.

## Features Implemented

### ✅ Phase 1: Authentication & Vehicles Management
- **Welcome Screen** - Malayalam welcome with vehicle carousel
- **Authentication** - Email/password login and registration in Malayalam
- **Dashboard** - Main navigation hub with 4 sections
- **Vehicles Management** - Complete CRUD operations for vehicles
  - Add new vehicles (മോഡൽ, നിർമ്മാതാവ്, insurance, tax, test, pollution dates)
  - Edit existing vehicles
  - Delete vehicles
  - View all vehicles with expiry dates

### ✅ Phase 2: Contracts & Trips Management
- **Contracts Management** (കരാറുകൾ)
  - Add/edit/delete contracts with vehicle assignment
  - Contract end date tracking for expiry notifications
  - Rate and distance management
- **Trips Management** (യാത്രകൾ)
  - Contract trips with auto-filled details from contracts
  - Savari trips with kilometer-based rate calculation
  - Driver salary calculation (25% default or manual)
  - Trip notes and client information
  - Driver salary payment tracking

### 🚧 Coming Next (Phase 3)
- **Reports & Summaries** (സംഗ്രഹങ്ങൾ)
- **Notifications** for document expiry
- **PDF Export** functionality

## Tech Stack

### Frontend (Flutter)
- Flutter with Dart
- Google Sign-In
- HTTP client for API calls
- Google Fonts (Noto Sans Malayalam)
- Material Design with Malayalam UI

### Backend (Node.js)
- Express.js server
- MongoDB with Mongoose
- RESTful APIs
- JWT authentication
- Google OAuth verification
- bcrypt password hashing

## Project Structure

```
yathra-rekha-app/
├── lib/                     # Flutter source code
│   ├── constants/          # App constants & strings
│   │   └── app_constants.dart
│   ├── models/             # Data models
│   │   └── vehicle.dart
│   ├── pages/              # UI screens
│   │   ├── welcome.dart
│   │   ├── sign.dart
│   │   ├── register.dart
│   │   ├── dashboard.dart
│   │   └── vehicles_page.dart
│   ├── services/           # Firebase services
│   │   └── vehicle_service.dart
│   ├── theme/              # App theming
│   │   └── app_theme.dart
│   ├── utils/              # Utility functions
│   │   └── date_utils.dart
│   ├── widgets/            # Reusable widgets
│   │   ├── custom_button.dart
│   │   └── date_picker_field.dart
│   └── main.dart          # App entry point
├── backend/                # Node.js API server
│   ├── models/            # MongoDB models
│   ├── routes/            # API routes
│   ├── server.js          # Express server
│   └── package.json
└── pubspec.yaml           # Flutter dependencies
```

## Setup Instructions

### Prerequisites
1. Install Flutter SDK (https://flutter.dev/docs/get-started/install)
2. Install Node.js (https://nodejs.org/)
3. Install MongoDB (https://www.mongodb.com/try/download/community) or use MongoDB Atlas
4. Get Google OAuth Client ID (https://console.developers.google.com/)

### Backend Setup
1. Navigate to backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Update `.env` file with your credentials:
   ```
   MONGODB_URI=mongodb://localhost:27017/yathra-rekha
   PORT=3000
   JWT_SECRET=your-super-secret-jwt-key-here
   GOOGLE_CLIENT_ID=your-google-client-id-here
   ```
4. Start the server:
   ```bash
   npm run dev
   ```

### Flutter App Setup
1. Navigate to project root:
   ```bash
   cd ..
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Malayalam UI Elements

The app is designed with Malayalam-first approach:
- All labels and buttons in Malayalam
- Date formats in DD/MM/YYYY
- User-friendly Malayalam error messages
- Intuitive navigation for non-English speakers

## Database Schema

### Vehicles Collection
```javascript
{
  model: String,           // വാഹന മോഡൽ
  manufacturer: String,    // നിർമ്മാതാവ്
  insuranceExpiry: Date,   // ഇൻഷുറൻസ് അവസാന തിയതി
  taxDate: Date,          // ടാക്സ് തീയതി
  testDate: Date,         // ടെസ്റ്റ് തീയതി
  pollutionDate: Date,    // പൊള്യൂഷൻ തീയതി
  userId: String,         // User ID
  createdAt: Date,        // Created timestamp
  updatedAt: Date         // Updated timestamp
}
```

## Development Progress

- [x] Project setup and structure
- [x] Authentication flow
- [x] Dashboard navigation
- [x] Vehicles CRUD operations
- [x] Backend API for vehicles
- [x] Contracts management
- [x] Trips management
  - [x] Contract trips with auto-fill from contracts
  - [x] Savari trips with km-based calculations
  - [x] Driver salary calculation and tracking
  - [x] Trip notes and client management
- [ ] Reports and summaries
- [ ] Document expiry notifications
- [ ] PDF export functionality

## Next Steps

1. **Contracts Feature**: Create contract management with vehicle assignment
2. **Trips Feature**: Add trip logging with contract/single trip options
3. **Reports**: Monthly revenue, profit/loss by vehicle
4. **Notifications**: Document expiry reminders
5. **Data Export**: PDF generation for reports

This is a progressive development approach - each feature is built completely before moving to the next one.