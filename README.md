# DiaMetrics

DiaMetrics is a comprehensive, open-source HealthTech UI/UX template and framework designed explicitly for diabetes management apps. Built with a rigid MVVM architecture, offline-first SQLite synchronization, and robust HIPAA-compliant security methodologies. 

## 🏗 Architectural Blueprint

```
lib/
├── core/
│   ├── database/        # SQLite setup and connection
│   ├── security/        # Secure storage and biometric auth handles
│   ├── theme/           # Design system tokens and styles
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable, stateless UI components (e.g. SensitiveDataOverlay)
├── models/              # Freezed strongly-typed data structures
├── repositories/        # Data access layer (abstracts generic db/api calls)
├── services/            # Business & external (API) capabilities
├── viewmodels/          # StateNotifier/Riverpod classes managing logic
└── views/               # Presentation layer screens
    ├── dashboard/       # Main hub and analytics
    ├── onboarding/      # Progressive user setup
    └── settings/        # Preferences and security configuration
```

## 🔒 HIPAA Compliance & Security Outline
This application is designed as a secure foundation for health information:
- **Local Storage Security**: `flutter_secure_storage` encrypts access tokens and profile identifiers.
- **Biometric Enforcement**: `local_auth` provides secondary interactions for revealing intentionally obscured health data (`SensitiveDataOverlay`). 
- **Offline Reliability**: Synchronized with SQFlite for offline resilience.
- **Cloud Backend Readiness**: Repository interfaces are prepared to transmit encrypted payloads securely to cloud providers when activated.

## 🎨 Token-Based Design System
The UI utilizes a strict set of Design Tokens extracted directly from Figma into `lib/core/theme/app_tokens.dart`. UI components **must not** define loose colors or typography directly—all styling inherits from `AppThemeTokens` bound to the standard Material 3 context. 

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: flutter_riverpod
- **Local Database**: SQFlite, SQLite3
- **Data Modeling**: freezed, json_serializable
- **Security**: flutter_secure_storage, local_auth

## 🚀 Setup & Execution 

1. **Install Dependencies**
```bash
flutter pub get
```

2. **Run Code Generation (Freezed/JSON)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. **Compile and Run**
```bash
flutter run
```