# Service User App

A modern Flutter mobile application for customers to book services from various service providers. This app allows users to discover service providers, book appointments, manage their profile, and receive notifications. This is the customer-facing app that works alongside a separate service provider app.

## 📱 Features

### Core Features
- **User Authentication**: Secure login and registration system for customers
- **Service Discovery**: Browse and search for nearby service providers and their offerings
- **Service Booking**: Schedule appointments with preferred service providers and time slots
- **Real-time Notifications**: Receive booking confirmations, reminders, and updates
- **Profile Management**: Manage personal information and service preferences
- **Messaging**: In-app communication with service providers
- **Payment Integration**: Secure payment processing with Stripe
- **QR Code Scanning**: Quick check-in and service provider information access

### Technical Features
- **API Integration**: Fully integrated with backend REST APIs for all service operations
- **Multi-language Support**: Internationalization with translation capabilities
- **Responsive Design**: Optimized for various screen sizes using ScreenUtil
- **Real-time Updates**: Socket.io integration for live updates
- **Local Storage**: Persistent data storage with GetStorage
- **Image Handling**: Image capture, cropping, and caching
- **WebView Integration**: In-app web content display

## 🛠 Tech Stack

### Core Framework
- **Flutter**: 3.35.6 (managed via FVM)
- **Dart**: ^3.7.2

### State Management & Architecture
- **GetX**: State management, dependency injection, and routing
- **Clean Architecture**: Feature-based modular structure

### Key Dependencies
- **Networking**: Dio for HTTP requests with logging
- **Real-time Communication**: Socket.io client
- **Local Storage**: GetStorage, SharedPreferences
- **Notifications**: Flutter Local Notifications
- **UI Components**: 
  - Google Fonts
  - Flutter SVG
  - Cached Network Images
  - Table Calendar
  - Pin Code Fields
  - Country Picker
- **Media Handling**: Image Picker, Image Cropper
- **WebView**: WebView Flutter
- **Payment**: Stripe WebView integration
- **Utilities**: 
  - Flutter ScreenUtil for responsive design
  - International support
  - URL Launcher
  - Share Plus
  - QR Flutter

## 📁 Project Structure

```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # App entry point
├── component/              # Reusable UI components
├── config/                 # Configuration files
│   ├── dependency/         # Dependency injection
│   ├── languages/          # Translations
│   ├── route/             # App routing
│   └── theme/             # App themes
├── features/              # Feature modules
│   ├── appointment/       # Appointment booking
│   ├── auth/             # Authentication
│   ├── home/             # Home screen
│   ├── message/          # Messaging
│   ├── notifications/    # Push notifications
│   ├── profile/          # User profile
│   ├── scan/             # QR scanning
│   ├── setting/          # App settings
│   └── splash/           # Splash screen
├── services/             # External services
│   ├── notification/     # Notification service
│   ├── socket/          # Socket service
│   └── storage/         # Storage service
└── utils/               # Utility functions
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.6 (managed via FVM)
- Dart SDK ^3.7.2
- Android Studio / VS Code with Flutter extensions
- For iOS: Xcode and iOS Simulator
- For Android: Android SDK and Android Virtual Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd haircutmen_user_app
   ```

2. **Install Flutter Version Manager (FVM)**
   ```bash
   dart pub global activate fvm
   ```

3. **Install the required Flutter version**
   ```bash
   fvm install 3.35.6
   fvm use 3.35.6
   ```

4. **Install dependencies**
   ```bash
   fvm flutter pub get
   ```

5. **Environment Setup**
   - Copy `.env.example` to `.env` (if available)
   - Add your API keys and configuration values to `.env`

6. **Run the app**
   ```bash
   # For development
   fvm flutter run
   
   # For specific platform
   fvm flutter run -d ios
   fvm flutter run -d android
   ```

## 🔧 Development

### Code Style
- Follow Flutter/Dart official style guidelines
- Use `flutter_lints` for code quality
- Maintain clean architecture principles


### Environment Variables
The app uses `.env` files for configuration. Ensure these variables are set:
- API base URLs
- Socket server configuration
- Notification settings
- Third-party service keys

## 📱 Platform Support

- **Android**: Minimum SDK 21 (Android 5.0)
- **iOS**: Minimum iOS 11.0
- **Web**: Supported via Flutter web
- **Desktop**: Linux, macOS, Windows support available

## 🔐 Security Considerations

- API communication uses HTTPS
- Sensitive data stored securely in local storage
- Authentication tokens managed properly
- Environment variables for configuration secrets

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🐛 Issues & Support

For bug reports and feature requests, please use the GitHub issue tracker.

## 📞 Contact

For any inquiries or support, please contact.
email: anikd5656@gmail.com

---

**Note**: This is a customer-facing application for booking services from various service providers. It works alongside a separate service provider app. Ensure proper backend API endpoints are configured for full functionality.
This is the github link of provider app: https://github.com/AnikDas08/provider_part
