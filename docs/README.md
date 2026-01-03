# Flutter P2P Chat Application Documentation

## Overview

This is a peer-to-peer (P2P) chat application built with Flutter and Dart. The application enables direct communication between users without a central server, using WebRTC for data transmission and MQTT for signaling. It supports multiple platforms including Android, iOS, Linux, macOS, Windows, and Web.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Communication Flow](#communication-flow)
3. [Core Components](#core-components)
4. [Technology Stack](#technology-stack)
5. [Setup and Installation](#setup-and-installation)
6. [Diagrams](#diagrams)

## Architecture Overview

The application follows SOLID principles with a clean, layered architecture:

- **Presentation Layer**: Flutter widgets for UI
- **Service Layer**: Business logic and communication services
- **Repository Layer**: Data persistence using Drift (SQLite)
- **Infrastructure Layer**: WebRTC and MQTT implementations

### Key Design Principles

- **Single Responsibility**: Each service handles one specific concern
- **Interface Segregation**: Focused interfaces for each service
- **Dependency Inversion**: Services depend on abstractions, not concrete implementations
- **Open/Closed**: Extensible through interfaces without modifying existing code

## Communication Flow

The application uses a hybrid communication model:

1. **Signaling Phase** (MQTT):
   - User discovery
   - Connection negotiation
   - SDP (Session Description Protocol) exchange
   - ICE candidate exchange

2. **Data Transfer Phase** (WebRTC):
   - Direct peer-to-peer messaging
   - Real-time communication
   - No server intermediary

## Core Components

### Services

#### 1. ChatCoordinator
- **Purpose**: Orchestrates all chat services
- **Responsibilities**:
  - Initializes and coordinates all services
  - Manages message flow
  - Handles contact management
  - Provides unified API for UI

#### 2. SignalingService (MQTT)
- **Purpose**: Handles signaling communication
- **Responsibilities**:
  - Connects to MQTT broker
  - Sends/receives signaling messages
  - Manages connection state
  - Implements retry logic with exponential backoff

#### 3. WebRtcService
- **Purpose**: Manages peer-to-peer connections
- **Responsibilities**:
  - Creates and manages RTCPeerConnection
  - Handles SDP offer/answer exchange
  - Manages ICE candidates
  - Sends/receives messages via data channel
  - Implements polite peer pattern for glare handling

#### 4. ConnectionManager
- **Purpose**: Manages WebRTC connection lifecycle
- **Responsibilities**:
  - Initiates connections
  - Monitors connection health
  - Handles reconnection logic
  - Manages presence heartbeats

#### 5. MessagingService
- **Purpose**: Handles message operations
- **Responsibilities**:
  - Sends messages via WebRTC
  - Persists messages to database
  - Manages pending messages
  - Handles message delivery status

#### 6. ContactService
- **Purpose**: Manages contacts
- **Responsibilities**:
  - Add/remove contacts
  - Handle contact requests
  - Manage contact status
  - Persist contact data

### Repositories

#### MessageRepository
- Stores messages in SQLite via Drift
- Retrieves message history
- Updates message status
- Manages pending messages

#### ContactRepository
- Stores contact information
- Manages contact list
- Handles soft deletes
- Tracks contact status

### Database (Drift)

The application uses Drift (formerly Moor) for type-safe SQL database access:

- **Messages Table**: Stores all chat messages
- **Contacts Table**: Stores contact information
- **Type-safe queries**: Compile-time verified SQL
- **Reactive streams**: Real-time UI updates

## Technology Stack

### Core Technologies
- **Flutter SDK**: Cross-platform UI framework
- **Dart 3.10.1+**: Programming language

### Communication
- **mqtt_client 10.2.0**: MQTT protocol implementation
- **flutter_webrtc 0.9.48**: WebRTC for Flutter
- **json_rpc_2 3.0.2**: JSON-RPC support

### Storage
- **drift 2.14.0**: Type-safe SQL database
- **sqlite3_flutter_libs 0.5.0**: SQLite native libraries
- **path_provider 2.1.0**: File system paths

### State Management
- **flutter_riverpod 2.4.9**: Reactive state management
- **riverpod_annotation 2.3.3**: Code generation for Riverpod

### Code Generation
- **freezed 2.4.6**: Immutable data classes
- **json_serializable 6.7.1**: JSON serialization
- **build_runner 2.4.7**: Code generation runner

### Utilities
- **uuid 4.2.2**: Unique ID generation
- **logger 2.0.2**: Logging
- **intl 0.19.0**: Internationalization
- **google_fonts 6.1.0**: Custom fonts

## Setup and Installation

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK (3.10.1 or higher)
- MQTT broker (e.g., Mosquitto)
- Platform-specific requirements:
  - **Android**: Android Studio, Android SDK
  - **iOS**: Xcode, CocoaPods
  - **Linux**: GTK development libraries
  - **Windows**: Visual Studio 2019+
  - **macOS**: Xcode
  - **Web**: Chrome/Edge browser

### Installation Steps

1. **Navigate to project directory**
   ```bash
   cd p2p_chat_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure MQTT broker**
   - Update MQTT broker URL in `lib/services/mqtt_service.dart`
   - Default: `ws://localhost:9001`

5. **Run on desired platform**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Linux
   flutter run -d linux
   
   # Windows
   flutter run -d windows
   
   # macOS
   flutter run -d macos
   
   # Web
   flutter run -d chrome
   ```

6. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS IPA
   flutter build ios --release
   
   # Linux executable
   flutter build linux --release
   
   # Windows executable
   flutter build windows --release
   
   # macOS app
   flutter build macos --release
   
   # Web
   flutter build web --release
   ```

## Diagrams

For detailed diagrams including:
- Use Case Diagram
- Sequence Diagrams
- Component Diagram
- Communication Flow Diagram
- State Diagrams

Please refer to the individual diagram files in this `docs` directory:
- [Use Case Diagram](./use-case-diagram.md)
- [Sequence Diagrams](./sequence-diagrams.md)
- [Component Architecture](./component-architecture.md)
- [Communication Flow](./communication-flow.md)
- [State Diagrams](./state-diagrams.md)

## Project Structure

```
p2p_chat_flutter/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── interfaces.dart        # Service interfaces
│   ├── database/              # Drift database
│   │   └── database.dart
│   ├── models/                # Data models
│   │   ├── message.dart
│   │   ├── signaling_message.dart
│   │   └── ...
│   ├── services/              # Business logic services
│   │   ├── chat_coordinator.dart
│   │   ├── mqtt_service.dart
│   │   ├── signaling_service.dart
│   │   ├── webrtc_service.dart
│   │   ├── connection_manager.dart
│   │   ├── messaging_service.dart
│   │   └── contact_service.dart
│   ├── repositories/          # Data repositories
│   │   ├── message_repository.dart
│   │   └── contact_repository.dart
│   ├── widgets/               # UI widgets
│   │   ├── chat_view.dart
│   │   ├── sidebar.dart
│   │   └── contact_dialog.dart
│   ├── utils/                 # Utility functions
│   │   └── retry_helper.dart
│   └── theme/                 # App theming
│       └── app_theme.dart
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── linux/                     # Linux platform code
├── windows/                   # Windows platform code
├── macos/                     # macOS platform code
├── web/                       # Web platform code
├── test/                      # Unit tests
├── docs/                      # Documentation
└── pubspec.yaml              # Dependencies
```

## Key Features

- ✅ Peer-to-peer messaging
- ✅ Contact management
- ✅ Message persistence (SQLite)
- ✅ Connection retry logic
- ✅ Presence detection
- ✅ Offline message queue
- ✅ Connection health monitoring
- ✅ Automatic reconnection
- ✅ Polite peer pattern for connection glare
- ✅ ICE candidate buffering
- ✅ Rollback support for failed negotiations
- ✅ Cross-platform support (Android, iOS, Linux, Windows, macOS, Web)
- ✅ Type-safe database with Drift
- ✅ Reactive state management with Riverpod

## Platform-Specific Considerations

### Android
- Minimum SDK: 21 (Android 5.0)
- Permissions: Internet, Camera, Microphone (for future features)

### iOS
- Minimum iOS: 12.0
- Permissions: Network access

### Linux
- GTK 3.0+ required
- WebRTC native support

### Windows
- Windows 10+ recommended
- Visual Studio 2019+ for building

### macOS
- macOS 10.14+ required
- Xcode for building

### Web
- Chrome, Edge, Firefox, Safari support
- WebRTC browser support required

## Development

### Code Generation

The project uses code generation for:
- **Drift**: Database code
- **Freezed**: Immutable models
- **Riverpod**: State providers
- **JSON Serializable**: JSON serialization

Run code generation:
```bash
flutter pub run build_runner watch
```

### Testing

Run tests:
```bash
flutter test
```

### Linting

Run linter:
```bash
flutter analyze
```

## License

Private project - not for public distribution
