# Project Instructions for Find Med Flutter Application

## 🎯 Project Purpose

This document provides comprehensive instructions for developers working on the **Find Med** Flutter application. This is a medical location-based service app that connects users with healthcare facilities and emergency services.

## 🚫 IMPORTANT: Do Not Remove Existing Code

**CRITICAL**: When working on this project, never remove or delete existing functional code. All modifications should be additive or improvements to existing functionality. If refactoring is needed, ensure backward compatibility and test thoroughly.

## 📁 Folder Structure Guide

### Core Architecture Pattern
The project follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── components/     # Reusable UI components (shared across pages)
├── pages/         # Screen-specific implementations
├── services/      # Business logic, API calls, and data services
├── utils/         # Helper functions and utilities
└── widgets/       # Custom reusable widgets
```

### Detailed Folder Responsibilities

#### `/lib/components/`
- **Purpose**: Shared UI components used across multiple pages
- **Examples**: Headers, footers, popups, loading indicators
- **Guidelines**: Keep components generic and reusable

#### `/lib/pages/`
- **Purpose**: Individual screen implementations
- **Structure**: Each major feature has its own subfolder
- **Examples**: `/agent/`, `/auth/`, `/home/`, `/map/`
- **Guidelines**: One primary screen per file, use widgets for complex UI parts

#### `/lib/services/`
- **Purpose**: Business logic and API integrations
- **Subfolders**: Organized by feature (auth, profile, etc.)
- **Examples**: `auth_service.dart`, `location_service.dart`
- **Guidelines**: Separate API calls from UI logic

#### `/lib/services/api/`
- **Purpose**: API endpoint definitions and HTTP client configurations
- **Structure**: Organized by feature modules
- **Examples**: `/auth/`, `/profile/`, `/home/`
- **Guidelines**: Use consistent error handling and response formatting

## 🏗️ Development Guidelines

### Code Standards
1. **Dart Style**: Follow official Dart style guide
2. **Widget Organization**: Keep widgets under 300 lines when possible
3. **State Management**: Use StatefulWidget with proper disposal
4. **Async Operations**: Always handle loading states and errors
5. **Constants**: Define app-wide constants in dedicated files

### File Naming Conventions
- Use snake_case for file names: `agent_register.dart`
- Use PascalCase for class names: `AgentRegisterPage`
- Be descriptive with names: `location_service.dart` not `service.dart`

### Import Organization
```dart
// Flutter imports first
import 'package:flutter/material.dart';

// Package imports second
import 'package:geolocator/geolocator.dart';

// Project imports third (use relative imports)
import '../../services/auth_service.dart';
import '../components/header.dart';
```

## 🔧 Development Setup

### Prerequisites
1. Flutter SDK >= 3.11.5
2. Dart SDK >= 3.0.0
3. VS Code or Android Studio with Flutter extensions
4. Git for version control

### Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd mobile-new

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Development Commands
```bash
# Debug mode
flutter run --debug

# Release mode
flutter run --release

# Clean build
flutter clean && flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📱 Platform-Specific Development

### Android Development
- Use Android Studio for Android-specific features
- Test on multiple Android versions
- Check AndroidManifest.xml for permissions
- Use Material Design components

### iOS Development
- Use Xcode for iOS-specific features
- Test on multiple iOS versions
- Configure Info.plist for permissions
- Use Cupertino design elements when appropriate

## 🌐 API Integration Guidelines

### Service Layer Pattern
```dart
class ExampleService {
  final ApiService _apiService = ApiService();
  
  Future<ResultType> methodName() async {
    try {
      final response = await _apiService.get('/endpoint');
      return ResultType.fromJson(response);
    } catch (e) {
      // Handle error appropriately
      throw Exception('Failed to fetch data: $e');
    }
  }
}
```

### Error Handling
- Always handle network errors gracefully
- Show user-friendly error messages
- Log technical errors for debugging
- Implement retry mechanisms where appropriate

### Authentication
- Use secure token storage
- Implement token refresh logic
- Handle authentication state changes
- Protect sensitive endpoints

## 📍 Location Services Implementation

### Permissions
- Request location permissions at runtime
- Handle permission denial gracefully
- Provide fallback functionality when location is unavailable

### Best Practices
```dart
// Example location service usage
try {
  final position = await LocationService.getCurrentPosition();
  // Use position data
} catch (e) {
  // Handle location errors
  // Show user message or use default location
}
```

## 🎨 UI/UX Guidelines

### Design System
- Use Material Design components
- Maintain consistent color scheme
- Follow accessibility guidelines
- Test on multiple screen sizes

### Component Reusability
- Create generic components in `/components/`
- Use parameters for customization
- Document component usage
- Test components in isolation

## 🧪 Testing Guidelines

### Unit Tests
- Test business logic in services
- Mock external dependencies
- Test edge cases and error conditions
- Aim for high code coverage

### Widget Tests
- Test UI components and interactions
- Verify widget state changes
- Test user workflows
- Use golden tests for visual regression

### Integration Tests
- Test complete user journeys
- Verify API integrations
- Test on real devices
- Include performance testing

## 🚀 Deployment Guidelines

### Build Process
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web
```

### Release Checklist
- [ ] Update version numbers
- [ ] Run full test suite
- [ ] Check for security vulnerabilities
- [ ] Verify API endpoints
- [ ] Test on target platforms
- [ ] Update documentation

## 🔐 Security Considerations

### Data Protection
- Use HTTPS for all API calls
- Encrypt sensitive data locally
- Implement proper authentication
- Validate all user inputs

### API Security
- Use API keys securely
- Implement rate limiting
- Validate request data
- Handle errors without exposing sensitive information

## 📝 Documentation Requirements

### Code Documentation
- Document public APIs
- Explain complex algorithms
- Provide usage examples
- Keep documentation updated

### README Updates
- Update feature descriptions
- Document new dependencies
- Include setup instructions
- Provide troubleshooting tips

## 🔄 Version Control Guidelines

### Git Workflow
- Use feature branches for new development
- Write descriptive commit messages
- Create pull requests for review
- Tag releases appropriately

### Branch Naming
- `feature/feature-name` for new features
- `bugfix/bug-description` for bug fixes
- `hotfix/critical-fix` for urgent fixes
- `release/version-number` for releases

## 🚨 Common Issues and Solutions

### Build Issues
- Run `flutter clean` if build fails
- Check dependency conflicts
- Verify Flutter and Dart versions
- Clear cache if necessary

### Performance Issues
- Profile app using Flutter DevTools
- Optimize widget rebuilds
- Use const constructors
- Implement lazy loading

### Platform-Specific Issues
- Check platform-specific configurations
- Verify permissions in platform files
- Test on actual devices
- Check platform-specific APIs

## 📞 Support and Collaboration

### Getting Help
1. Check this documentation first
2. Review existing code for similar implementations
3. Ask team members for guidance
4. Create issues for bugs or feature requests

### Code Review Process
- All code changes require review
- Focus on code quality and maintainability
- Test functionality before approval
- Update documentation as needed

---

## 🎯 Key Principles

1. **Don't break existing functionality**
2. **Write clean, maintainable code**
3. **Test thoroughly before deployment**
4. **Document your changes**
5. **Follow established patterns**
6. **Consider user experience in all decisions**
7. **Prioritize security and performance**
8. **Collaborate effectively with the team**

Remember: This is a medical application that users rely on for important health-related services. Quality, reliability, and user experience are paramount.
