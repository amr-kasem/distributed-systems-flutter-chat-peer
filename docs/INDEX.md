# Documentation Index - Flutter P2P Chat Application

## 📚 Documentation Overview

This directory contains comprehensive documentation for the Flutter P2P Chat Application, including architecture diagrams, communication flows, use cases, and technical specifications for cross-platform development.

## 📖 Documentation Files

### 1. [README.md](./README.md)
**Main documentation file** - Start here for an overview of the project.

**Contents:**
- Architecture overview
- Technology stack (Flutter, Dart, Riverpod, Drift)
- Setup and installation instructions for all platforms
- Core components description
- Project structure
- Platform-specific considerations
- Key features

### 2. [Use Case Diagram](./use-case-diagram.md)
**User interaction and system use cases**

**Contents:**
- System actors (User A, User B, MQTT Broker, WebRTC)
- 13 detailed use cases with descriptions
- Flutter-specific features (Riverpod, reactive UI)
- Use case flow diagrams
- Actor relationships
- Platform integration details
- Use case priorities (High/Medium/Low)

**Key Use Cases:**
- UC1: Register/Login
- UC2: Add Contact
- UC6: Send Message (with Riverpod state updates)
- UC9: Establish P2P Connection (with polite peer pattern)
- UC13: Sync Across Devices

### 3. [Communication Flow](./communication-flow.md)
**Detailed communication protocols and Flutter-specific implementation**

**Contents:**
- Flutter-specific architecture (Widgets, Riverpod, Services)
- MQTT signaling with mqtt_client package
- WebRTC connection with flutter_webrtc package
- Data persistence with Drift (SQLite)
- Polite peer pattern implementation
- Platform-specific considerations (Android, iOS, Desktop, Web)
- Performance optimizations (pagination, lazy loading)
- Security layers (DTLS, TLS, SQLite encryption)

### 4. [Component Architecture](./component-architecture.md)
**System architecture and Flutter component details**

**Contents:**
- Widget hierarchy and structure
- Riverpod provider architecture
- Service layer implementation
- Repository layer with Drift
- Data flow examples (send/receive messages)
- Cross-platform architecture
- Platform channels for native integration
- Type-safe database queries

**Key Components:**
- ChatCoordinator
- SignalingService (MQTT)
- WebRtcService (with polite peer pattern)
- ConnectionManager
- MessagingService
- ContactService
- MessageRepository (Drift)
- ContactRepository (Drift)

## 🎯 Quick Navigation

### For New Flutter Developers
1. Start with [README.md](./README.md) for project overview
2. Review [Component Architecture](./component-architecture.md) to understand Flutter architecture
3. Study [Communication Flow](./communication-flow.md) for Riverpod and Drift integration

### For Understanding User Flows
1. Check [Use Case Diagram](./use-case-diagram.md) for user interactions
2. Review [Communication Flow](./communication-flow.md) for detailed flows with Riverpod

### For Technical Implementation
1. Study [Component Architecture](./component-architecture.md) for service details
2. Review [Communication Flow](./communication-flow.md) for protocols and platform specifics
3. Understand Riverpod state management patterns
4. Learn Drift database queries and migrations

### For Cross-Platform Development
1. Review platform-specific sections in [README.md](./README.md)
2. Check [Communication Flow](./communication-flow.md) for platform channels
3. Study [Component Architecture](./component-architecture.md) for platform integration

## 🔑 Key Concepts

### SOLID Principles
All services follow SOLID principles:
- **S**ingle Responsibility: Each service has one clear purpose
- **O**pen/Closed: Extensible without modification
- **L**iskov Substitution: Services are interchangeable via interfaces
- **I**nterface Segregation: Focused, minimal interfaces
- **D**ependency Inversion: Depend on abstractions, not concretions

### Flutter-Specific Patterns

#### Riverpod State Management
- **Provider**: Immutable service instances
- **StateProvider**: Simple mutable state
- **StreamProvider**: Reactive data streams
- **FutureProvider**: Async data loading
- **StateNotifier**: Complex state management

#### Drift Database
- **Type-safe SQL**: Compile-time verification
- **Reactive queries**: Stream-based updates
- **Code generation**: Automatic DAO generation
- **Migrations**: Version management

### Communication Model
- **Signaling**: MQTT via mqtt_client package
- **Data Transfer**: WebRTC via flutter_webrtc package
- **Persistence**: Drift (SQLite) for local storage
- **State**: Riverpod for reactive UI updates

### Architecture Layers
1. **Presentation**: Flutter widgets (Material/Cupertino)
2. **State Management**: Riverpod providers
3. **Coordination**: ChatCoordinator orchestrates services
4. **Service**: Business logic (MQTT, WebRTC, etc.)
5. **Repository**: Data persistence (Drift)
6. **Infrastructure**: External systems (MQTT broker, WebRTC)

## 📊 Diagrams Summary

| Diagram Type | Count | Purpose |
|--------------|-------|---------|
| Use Case Diagrams | 2 | User interactions and system actors |
| Component Diagrams | 15+ | System structure and Flutter architecture |
| Flow Diagrams | 20+ | Data flow, state management, platform integration |
| Sequence Diagrams | 10+ | Component interactions with Riverpod |

## 🛠️ Technology Stack

### Core
- **Flutter SDK**: Cross-platform UI framework
- **Dart 3.10.1+**: Programming language

### Communication
- **mqtt_client 10.2.0**: MQTT protocol
- **flutter_webrtc 0.9.48**: WebRTC for Flutter

### Storage
- **drift 2.14.0**: Type-safe SQL database
- **sqlite3_flutter_libs 0.5.0**: SQLite native libraries

### State Management
- **flutter_riverpod 2.4.9**: Reactive state management
- **riverpod_annotation 2.3.3**: Code generation

### Code Generation
- **freezed 2.4.6**: Immutable data classes
- **json_serializable 6.7.1**: JSON serialization
- **build_runner 2.4.7**: Code generation runner

## 🌍 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | Min SDK 21 |
| iOS | ✅ Full Support | Min iOS 12.0 |
| Web | ✅ Full Support | Chrome, Edge, Firefox, Safari |
| Linux | ✅ Full Support | GTK 3.0+ |
| Windows | ✅ Full Support | Windows 10+ |
| macOS | ✅ Full Support | macOS 10.14+ |

## 📝 Documentation Standards

All diagrams use **Mermaid** syntax for:
- Version control friendly (text-based)
- Easy to update and maintain
- Renders in GitHub and most markdown viewers
- Supports various diagram types

## 🔗 Related Documentation

- **Main Project README**: [../README.md](../README.md)
- **React Implementation**: [../../chat-app-react/docs/](../../chat-app-react/docs/)
- **Cross-Project Comparison**: [../../COMPARISON.md](../../COMPARISON.md)

## 🚀 Quick Start

### Development
```bash
# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device
flutter run -d <device>
```

### Platform-Specific Builds
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

## 📧 Contributing to Documentation

When updating documentation:
1. Keep diagrams up-to-date with code changes
2. Update platform-specific sections when adding features
3. Include Riverpod provider examples
4. Document Drift schema changes
5. Update this index when adding new documentation
6. Follow existing diagram styles and formats
7. Test code examples on all platforms

## 🔄 Code Generation

Remember to run code generation after:
- Adding new Drift tables
- Creating new Riverpod providers with annotations
- Adding Freezed models
- Updating JSON serialization

```bash
flutter pub run build_runner watch
```

## 📅 Last Updated

This documentation was last updated: **January 3, 2026**

---

**Note**: This is a living documentation. As the project evolves, these documents should be updated to reflect the current state of the system across all supported platforms.
