# AnkaRota: Smart Transit Routing for Ankara

A clean, fast, and ad-free public transportation route finder specifically designed for Ankara, Turkey. Built with Flutter and following clean architecture principles.

## Overview

AnkaRota solves the frustrating problem of finding efficient public transport routes in Ankara. While existing solutions like EGO Mobile lack route planning features and alternatives like Moovit suffer from excessive ads and complex interfaces, AnkaRota provides a streamlined experience focused solely on getting you from point A to point B using Ankara's public transportation system.

## Features

- 🗺️ **Interactive Map View** - Clean Google Maps integration with route visualization
- 🚌 **Multi-Modal Transit** - Support for buses, metro, Ankaray, and walking combinations  
- 📍 **Smart Location Services** - GPS integration with location permissions handling
- ⚡ **Real-time Route Calculation** - Powered by Google Directions API
- 🎯 **Step-by-Step Navigation** - Detailed route instructions with transit information
- 📱 **Material Design UI** - Modern, user-friendly interface
- 🔄 **Reactive State Management** - Built with Riverpod for optimal performance

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Architecture**: Clean Architecture (Domain/Data/Presentation layers)
- **State Management**: Riverpod
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **HTTP Client**: Dio
- **JSON Serialization**: json_serializable
- **Environment**: flutter_dotenv

## Architecture

```
lib/
├── src/
│   ├── core/           # Configuration and utilities
│   ├── data/           # External data layer
│   │   ├── models/     # JSON models with serialization
│   │   ├── services/   # API and external services
│   │   └── repositories/ # Repository implementations
│   ├── domain/         # Business logic layer
│   │   ├── entities/   # Business models
│   │   ├── repositories/ # Repository interfaces
│   │   └── usecases/   # Application use cases
│   └── presentation/   # UI layer
│       ├── pages/      # Screen widgets
│       ├── widgets/    # Reusable UI components
│       └── providers/  # Riverpod state providers
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Google Cloud Platform account for Maps API

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ankarota.git
   cd ankarota
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Google Maps API**
   - Create a project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android and Directions API
   - Create API credentials and restrict them appropriately
   - Copy `.env.example` to `.env` and add your API key:
     ```
     GOOGLE_MAPS_API_KEY=your_api_key_here
     ```

5. **Run the application**
   ```bash
   flutter run
   ```

### API Key Security

- Never commit your actual API key to version control
- Use the provided `.env.example` as a template
- Configure API key restrictions in Google Cloud Console
- For production builds, use proper CI/CD secret management

## Development

### Running Tests
```bash
flutter test
```

### Code Generation
When modifying model classes, regenerate serialization code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Building for Release
```bash
flutter build apk --release
```

## Project Structure Highlights

- **Clean Architecture**: Separation of concerns with clear dependency inversion
- **Modular Design**: Each feature is self-contained and testable
- **Reactive UI**: State changes automatically update the interface
- **Error Handling**: Comprehensive error states and user feedback
- **Performance Optimized**: Efficient map rendering and API calls

## Contributing

This project follows clean code principles and maintains high code quality standards. Please ensure:

- Follow the existing architecture patterns
- Write tests for new features
- Use meaningful commit messages
- Update documentation as needed

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built as a portfolio project to demonstrate Flutter and mobile development skills
- Inspired by the need for better public transportation tools in Ankara
- Uses Google Maps Platform for accurate routing data