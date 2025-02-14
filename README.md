# Coffee Mapper Web Dashboard 🌱☕

<div align="center">

![Coffee Mapper Logo](https://i.ibb.co/zWyCyM2x/logo-white.png)


A comprehensive web dashboard application built with Flutter for tracking and managing coffee plantations in Koraput. The application provides real-time monitoring, data visualization, and management tools for coffee plantation initiatives.

[![Flutter](https://img.shields.io/badge/Flutter-^3.5.4-blue?style=for-the-badge&logo=flutter&logoColor=white&labelColor=02569B)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-^3.0.0-blue?style=for-the-badge&logo=dart&logoColor=white&labelColor=0175C2)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?style=for-the-badge&logo=firebase&logoColor=white&labelColor=FFCA28)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge&logo=license&logoColor=white&labelColor=34D058)](LICENSE)
[![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge&logo=github&logoColor=white&labelColor=238636)](CONTRIBUTING.md)
[![Developer](https://img.shields.io/badge/Developer-Amrit_Dash-blue?style=for-the-badge&logo=about.me&logoColor=white&labelColor=00A98F)](https://about.me/amritdash)
[![Twitter Follow](https://img.shields.io/twitter/follow/amritdash?style=for-the-badge&logo=twitter&logoColor=1DA1F2&labelColor=white)](https://twitter.com/amritdash)
[![Build](https://img.shields.io/github/actions/workflow/status/amrit-dash/coffee-mapper-web/flutter.yml?branch=main&style=for-the-badge&logo=github-actions&logoColor=white&labelColor=2088FF)](https://github.com/amrit-dash/coffee-mapper-web/actions)

[Features](#-features) • [Installation](#-getting-started) • [Contributing](#-contributing) • [Support](#-support)

<div align="center">

### 🌐 Live Deployments

[![Production](https://img.shields.io/badge/Production-Live-success.svg)](https://coffeemapper.web.app)
[![Development](https://img.shields.io/badge/Development-Live-yellow.svg)](https://coffee-mapper-dashboard.web.app)

Try out our [Production Environment](https://coffeemapper.web.app) or [Development Environment](https://coffee-mapper-dashboard.web.app)

</div>

</div>

## ✨ Features

<div align="center">
<img src="https://i.ibb.co/LdKkn58s/image-2025-02-14-073354846.png" alt="Dashboard Preview" width="800px"/>
</div>

### 📊 Real-time Dashboard
  - 📈 Live metrics and statistics
  - 📊 Interactive data visualization
  - 🎯 Comprehensive plantation overview
  - 📱 Progress tracking and monitoring

### 🌿 Plantation Management
  - ☕ Coffee plantation tracking
  - 🌳 Shade tree management
  - 📏 Area and perimeter calculations
  - 🗺️ Geolocation mapping

### 📋 Data Filtering & Analysis
  - 🔍 Multi-level filtering (District, Block, Village, Panchayat)
  - 📑 Region-based categorization
  - 📊 Performance metrics
  - 📈 Survival rate tracking

### 👥 User Management
  - 🔐 Secure authentication
  - 👮 Role-based access control
  - 👨‍💼 Admin dashboard
  - 📝 User activity tracking

### 🗺️ Interactive Maps
  - 🌍 Google Maps integration
  - 📍 Polygon visualization
  - 🚩 Boundary mapping
  - 📌 Location-based insights

### 📸 Media Management
  - 🖼️ Image galleries
  - 📄 Documentation storage
  - 📸 Boundary images
  - 📹 Progress documentation

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (^3.5.4)
- Dart SDK (^3.0.0)
- Firebase CLI
- A Google Maps API key
- Git

### 🔑 API Keys and Configuration

1. **Firebase Setup**:
   - Create two Firebase projects (development and production)
   - Enable Authentication, Firestore, and Hosting
   - Set up Firebase configuration:
     ```bash
     # Copy template files
     cp .github/templates/firebase.json.template firebase.json
     cp .github/templates/firestore.rules.template firestore.rules
     cp .github/templates/storage.rules.template storage.rules
     cp .github/templates/firestore.indexes.json.template firestore.indexes.json
     cp .github/templates/.firebaserc.template .firebaserc
     ```
   - Update the configuration files:
     - In `firebase.json`:
       - Replace `your-site-name` with your Firebase hosting site name
       - Update `your-region` with your preferred region (e.g., "asia-east1")
     - In `.firebaserc`:
       - Replace `your-project-id` with your default Firebase project ID
       - Update `your-dev-project-id` and `your-prod-project-id` with your development and production project IDs
       - Configure hosting targets for your sites
     - Update security rules in `firestore.rules` and `storage.rules`:
       - Replace the default open access rules with your security requirements
       - Uncomment and modify the example secured rules as needed
     - In `firestore.indexes.json`:
       - Replace the example index with your required Firestore indexes
       - Add additional indexes as needed for your queries

2. **Google Maps Setup**:
   - Create a Google Cloud Project
   - Enable Maps JavaScript API
   - Create API key with appropriate restrictions
   - Add the key to your environment configuration

### ⚡ Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/amrit-dash/coffee-mapper-web.git
   cd coffee_mapper_web
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   cp lib/config/firebase_options_dev.template.dart lib/config/firebase_options_dev.dart
   cp lib/config/firebase_options_prod.template.dart lib/config/firebase_options_prod.dart
   ```

4. Set up environment variables:
   ```bash
   cp .env.template .env
   ```
   Update the following in your `.env` file:
   ```
   GOOGLE_MAPS_API_KEY=your_api_key
   FIREBASE_API_KEY=your_firebase_key
   ```

5. Run the application:
   ```bash
   flutter run -d chrome
   ```

### 🔧 Environment Setup

#### Development Environment
```bash
# Install Firebase tools
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init

# Select features:
# - Firestore
# - Hosting
# - Authentication
```

#### Production Environment
```bash
# Deploy to production
./deploy.sh prod

# Deploy to development
./deploy.sh dev
```

<details>
<summary>📱 Supported Platforms</summary>

| Platform | Support |
|----------|---------|
| Web      | ✅      |
| Android  | 🚧      |
| iOS      | 🚧      |
| Windows  | ❌      |
| macOS    | ❌      |
| Linux    | ❌      |

</details>

## 🔧 Development vs Production

The application supports both development and production environments:

### 🛠️ Development
```bash
./deploy.sh dev
```
- Uses development Firebase project
- Enables debugging features
- Development-specific configurations
- Live at: [coffee-mapper-dashboard.web.app](https://coffee-mapper-dashboard.web.app)

### 🚀 Production
```bash
./deploy.sh prod
```
- Uses production Firebase project
- Optimized performance
- Production-specific security rules
- Live at: [coffeemapper.web.app](https://coffeemapper.web.app)

## 🏗️ Project Structure

```
lib/
├── config/          # ⚙️ Configuration files
├── models/          # 📦 Data models
├── screens/         # 📱 Application screens
├── services/        # 🔧 Business logic and API services
├── utils/          # 🛠️ Utility functions
└── widgets/        # 🎨 Reusable UI components
    ├── dialogs/    # 💬 Dialog components
    ├── forms/      # 📝 Form components
    ├── layout/     # 🎯 Layout components
    ├── map/        # 🗺️ Map-related components
    └── tables/     # 📊 Data table components
```

## 🔒 Security

- 🔐 Firebase Authentication for user management
- 🔑 Secure API key handling
- 🛡️ Environment-specific security rules
- 🔒 Data access control
- 🔄 Regular security updates

> ⚠️ **Important Security Note**: The template files in `.github/templates/` contain open access rules for demonstration purposes only. Never use these rules in production. Always implement proper security rules based on your application's requirements before deploying.

## 🤝 Contributing

We love your input! Check out our [Contributing Guidelines](CONTRIBUTING.md) to get started.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Core Team

<div align="center">
<a href="https://about.me/amritdash">
<img src="https://avatars.githubusercontent.com/amrit-dash" width="100px" alt="Amrit Dash"/>
<br/>
<b>Amrit Dash</b>
</a>
<br/>
<a href="https://about.me/amritdash">🌐</a> • 
<a href="https://github.com/amrit-dash">🐙</a>
</div>

## 🙏 Acknowledgments

* 🎯 Flutter Team for the amazing framework
* 🔥 Firebase for backend services
* 🗺️ Google Maps Platform for mapping services

## 🔧 Technical Details

### 📝 Firestore Rules Configuration

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Common functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data != null;
    }

    // Collection access rules
    match /plantations/{document=**} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    match /metrics/{document=**} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow write: if isAdmin();
    }
  }
}
```

### 🚀 Deployment Process

#### Development Deployment
```bash
# 1. Build the web app
flutter build web --web-renderer canvaskit --release --dart-define=ENVIRONMENT=development

# 2. Deploy to Firebase Hosting (Development)
firebase use development
firebase deploy --only hosting

# Alternative: Use deployment script
./deploy.sh dev
```

#### Production Deployment
```bash
# 1. Build the web app with optimizations
flutter build web --web-renderer canvaskit --release --dart-define=ENVIRONMENT=production

# 2. Deploy to Firebase Hosting (Production)
firebase use production
firebase deploy --only hosting

# Alternative: Use deployment script
./deploy.sh prod
```

### 🧪 Testing Guidelines

#### Unit Tests
```dart
// Example test structure
void main() {
  group('Plantation Service Tests', () {
    late PlantationService plantationService;
    
    setUp(() {
      plantationService = PlantationService();
    });
    
    test('should calculate area correctly', () {
      final coordinates = [
        LatLng(0, 0),
        LatLng(0, 1),
        LatLng(1, 1),
        LatLng(1, 0),
      ];
      
      final area = plantationService.calculateArea(coordinates);
      expect(area, closeTo(111.32, 0.01));
    });
  });
}
```

#### Integration Tests
```bash
# Run integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
```

#### Performance Testing
```bash
# Run performance tests
flutter run --profile --trace-skia
```

#### Test Coverage
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📞 Support

For support and inquiries:
- 📧 Support Email: geospatialtech.production@gmail.com
- 👨‍💻 Developer Contact: amrit.dash60@gmail.com
- 📚 Links Document: [Coffee Mapper Links](https://docs.google.com/document/d/1tTvSK8hoXd7UaeSKX60f-Dl1YoWcQjqIl2ckJ6YS2qU/edit?usp=sharing)

---

<div align="center">

Made with ❤️ for Koraput's Coffee Farming Community

[Website](https://coffeemapper.web.app)

</div>
