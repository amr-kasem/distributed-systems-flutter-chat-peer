# Communication Flow - Flutter P2P Chat

## Overview

The Flutter P2P chat application uses the same hybrid communication model as the React version, combining MQTT for signaling and WebRTC for data transfer. This document details the Flutter-specific implementation.

## Communication Layers

```mermaid
graph TB
    subgraph "Flutter Application Layer"
        Widgets["Flutter Widgets"]
        Riverpod["Riverpod State"]
        Services["Service Layer"]
    end
    
    subgraph "Transport Layer"
        MQTT["MQTT Client<br/>mqtt_client package"]
        WebRTC["Flutter WebRTC<br/>flutter_webrtc package"]
    end
    
    subgraph "Persistence Layer"
        Drift["Drift Database<br/>SQLite"]
    end
    
    subgraph "Network Layer"
        Broker["MQTT Broker"]
        STUN["STUN Server"]
        TURN["TURN Server"]
    end
    
    Widgets --> Riverpod
    Riverpod --> Services
    Services --> MQTT
    Services --> WebRTC
    Services --> Drift
    MQTT --> Broker
    WebRTC --> STUN
    WebRTC --> TURN
    
    style MQTT fill:#ffb74d
    style WebRTC fill:#81c784
    style Drift fill:#ba68c8
    style Broker fill:#ef5350
```

## 1. Flutter-Specific Architecture

### Widget Tree

```mermaid
graph TB
    MaterialApp[MaterialApp]
    MaterialApp --> ChatView["ChatView Widget"]
    ChatView --> Sidebar["Sidebar Widget"]
    ChatView --> ChatArea["Chat Area"]
    
    Sidebar --> ContactList["Contact List"]
    ContactList --> ContactTile1["Contact Tile"]
    ContactList --> ContactTile2["Contact Tile"]
    
    ChatArea --> MessageList["Message ListView"]
    ChatArea --> InputField[TextField]
    
    MessageList --> MessageBubble1["Message Bubble"]
    MessageList --> MessageBubble2["Message Bubble"]
    
    style ChatView fill:#4fc3f7
    style Sidebar fill:#81c784
    style ChatArea fill:#ffb74d
```

### Riverpod State Flow

```mermaid
sequenceDiagram
    participant Widget
    participant Provider
    participant Coordinator
    participant Service
    participant Drift
    
    Widget->>Provider: ref.watch(provider)
    Provider->>Coordinator: Get state
    Coordinator->>Service: Fetch data
    Service->>Drift: Query database
    Drift-->>Service: Data stream
    Service-->>Coordinator: Process data
    Coordinator-->>Provider: Update state
    Provider-->>Widget: Rebuild UI
```

## 2. MQTT Signaling (Flutter Implementation)

### MQTT Client Configuration

```dart
// Flutter-specific MQTT setup
final client = MqttServerClient('ws://localhost', '');
client.port = 9001;
client.websocketProtocols = ['mqtt'];
client.logging(on: true);
client.keepAlivePeriod = 60;
client.onConnected = onConnected;
client.onDisconnected = onDisconnected;
client.onSubscribed = onSubscribed;
```

### Message Flow with Riverpod

```mermaid
sequenceDiagram
    participant UserA as User A Widget
    participant ProviderA as Riverpod Provider A
    participant CoordA as ChatCoordinator A
    participant MQTT_A as SignalingService A
    participant Broker as MQTT Broker
    participant MQTT_B as SignalingService B
    participant CoordB as ChatCoordinator B
    participant ProviderB as Riverpod Provider B
    participant UserB as User B Widget
    
    UserA->>ProviderA: Tap send contact request
    ProviderA->>CoordA: addContact("peerId, name")
    CoordA->>MQTT_A: sendSignalingMessage()
    MQTT_A->>Broker: PUBLISH user/B/contactRequest
    Broker->>MQTT_B: FORWARD contactRequest
    MQTT_B->>CoordB: onSignalingMessage()
    CoordB->>ProviderB: Notify listeners
    ProviderB->>UserB: Rebuild with dialog
```

## 3. WebRTC Connection (Flutter Implementation)

### RTCPeerConnection Setup

```dart
// Flutter WebRTC configuration
final configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ],
  'sdpSemantics': 'unified-plan',
};

final pc = await createPeerConnection(configuration);
```

### Data Channel Creation

```mermaid
sequenceDiagram
    participant App
    participant WebRTC as WebRtcService
    participant PC as RTCPeerConnection
    participant DC as RTCDataChannel
    
    App->>WebRTC: Initialize
    WebRTC->>PC: createPeerConnection()
    PC-->>WebRTC: PeerConnection
    WebRTC->>PC: createDataChannel('chat')
    PC-->>WebRTC: DataChannel
    WebRTC->>DC: Configure callbacks
    DC->>WebRTC: onDataChannelState
    DC->>WebRTC: onMessage
    
    Note over DC: Data channel open
    
    App->>WebRTC: sendMessage(content)
    WebRTC->>DC: send(RTCDataChannelMessage)
    DC-->>WebRTC: Message sent
```

### Polite Peer Pattern (Flutter)

```mermaid
sequenceDiagram
    participant A as "Peer A (Polite)"
    participant B as "Peer B (Impolite)"
    
    Note over A,B: Simultaneous Offers (Glare)
    
    A->>A: createOffer()
    B->>B: createOffer()
    
    A->>B: Send offer
    B->>A: Send offer
    
    Note over A: Receives offer while waiting
    
    A->>A: rollback()
    A->>A: setRemoteDescription("B offer")
    A->>A: createAnswer()
    A->>B: Send answer
    
    Note over B: Receives offer while waiting
    
    B->>B: Ignore A offer
    B->>A: Wait for answer
    
    B->>B: setRemoteDescription("A answer")
    
    Note over A,B: Connection established
```

## 4. Data Persistence (Drift)

### Database Schema

```dart
@DataClassName('MessageData')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get contactId => text()();
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSent => boolean()();
  TextColumn get status => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ContactData')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Reactive Queries

```mermaid
sequenceDiagram
    participant Widget
    participant Provider
    participant Repo as MessageRepository
    participant Drift as Drift Database
    
    Widget->>Provider: ref.watch(messagesProvider)
    Provider->>Repo: watchMessages(contactId)
    Repo->>Drift: select().watch()
    Drift-->>Repo: Stream<List<Message>>
    Repo-->>Provider: Stream updates
    Provider-->>Widget: Auto rebuild on changes
    
    Note over Widget: User sends message
    
    Widget->>Provider: sendMessage()
    Provider->>Repo: saveMessage()
    Repo->>Drift: insert()
    Drift-->>Repo: Inserted
    Drift-->>Repo: Stream emits update
    Repo-->>Provider: New message list
    Provider-->>Widget: Rebuild with new message
```

## 5. Message Send Flow (Flutter)

```mermaid
sequenceDiagram
    participant User
    participant ChatView as ChatView Widget
    participant Provider as ChatProvider
    participant Coord as ChatCoordinator
    participant MsgSvc as MessagingService
    participant WebRTC as WebRtcService
    participant Drift as Drift DB
    
    User->>ChatView: Type message
    User->>ChatView: Tap send
    ChatView->>Provider: sendMessage(content)
    Provider->>Coord: sendMessage(content)
    Coord->>MsgSvc: sendMessage(content)
    
    MsgSvc->>MsgSvc: Create Message with UUID
    MsgSvc->>Drift: saveMessage("status: pending")
    Drift-->>MsgSvc: Saved
    
    MsgSvc->>WebRTC: sendMessage(content)
    WebRTC->>WebRTC: RTCDataChannelMessage
    WebRTC-->>MsgSvc: Sent
    
    MsgSvc->>Drift: updateStatus(delivered)
    Drift-->>MsgSvc: Updated
    Drift-->>Provider: Stream update
    Provider-->>ChatView: Rebuild with status
```

## 6. Connection Lifecycle (Flutter)

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Initializing: App launch
    Initializing --> ConnectingMQTT: Initialize services
    ConnectingMQTT --> MQTTConnected: MQTT connected
    MQTTConnected --> Ready: Services ready
    Ready --> SelectingContact: User taps contact
    SelectingContact --> CreatingOffer: Initiate WebRTC
    CreatingOffer --> OfferSent: Send via MQTT
    OfferSent --> WaitingAnswer: Waiting
    WaitingAnswer --> SettingAnswer: Answer received
    SettingAnswer --> ICEGathering: Exchange candidates
    ICEGathering --> Connected: Connection established
    Connected --> ChatActive: Data channel open
    ChatActive --> Disconnected: Network loss
    Disconnected --> Reconnecting: Auto reconnect
    Reconnecting --> CreatingOffer: Retry
    ChatActive --> Closing: User closes chat
    Closing --> Ready: Cleanup
    
    note right of ChatActive
        Messages flowing
        Drift saving
        UI updating
    end note
```

## 7. Error Handling (Flutter)

### Retry with Exponential Backoff

```dart
class RetryHelper {
  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 5,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        
        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
    throw Exception('Max retries reached');
  }
}
```

### Error Flow

```mermaid
sequenceDiagram
    participant Service
    participant Retry as RetryHelper
    participant Logger
    participant UI
    
    Service->>Retry: withRetry(operation)
    
    loop Retry attempts
        Retry->>Retry: Attempt operation
        
        alt Success
            Retry-->>Service: Return result
        else Failure
            Retry->>Logger: Log error
            Retry->>Retry: Calculate backoff
            Retry->>Retry: Wait delay
        end
    end
    
    alt Max retries reached
        Retry->>Logger: Log final failure
        Retry->>UI: Show error snackbar
        Retry-->>Service: Throw exception
    end
```

## 8. Platform-Specific Considerations

### Android

```mermaid
graph TB
    FlutterApp["Flutter App"]
    FlutterApp --> MethodChannel["Method Channel"]
    MethodChannel --> AndroidCode["Android Native Code"]
    AndroidCode --> WebRTC["WebRTC Android"]
    AndroidCode --> MQTT["MQTT Android"]
    
    style FlutterApp fill:#4fc3f7
    style AndroidCode fill:#81c784
```

### iOS

```mermaid
graph TB
    FlutterApp["Flutter App"]
    FlutterApp --> MethodChannel["Method Channel"]
    MethodChannel --> iOSCode["iOS Native Code"]
    iOSCode --> WebRTC["WebRTC iOS"]
    iOSCode --> MQTT["MQTT iOS"]
    
    style FlutterApp fill:#4fc3f7
    style iOSCode fill:#81c784
```

### Desktop (Linux/Windows/macOS)

```mermaid
graph TB
    FlutterApp["Flutter App"]
    FlutterApp --> FFI["Dart FFI"]
    FFI --> NativeLib["Native Libraries"]
    NativeLib --> WebRTC["WebRTC Native"]
    NativeLib --> MQTT["MQTT Native"]
    
    style FlutterApp fill:#4fc3f7
    style NativeLib fill:#81c784
```

### Web

```mermaid
graph TB
    FlutterApp["Flutter Web App"]
    FlutterApp --> JSInterop["JS Interop"]
    JSInterop --> WebAPI["Web APIs"]
    WebAPI --> WebRTC["WebRTC Browser"]
    WebAPI --> WebSocket["WebSocket MQTT"]
    
    style FlutterApp fill:#4fc3f7
    style WebAPI fill:#81c784
```

## 9. Performance Optimizations

### Message Pagination

```dart
// Drift query with pagination
Stream<List<Message>> watchMessages(String contactId, {int limit = 50}) {
  return (select(messages)
    ..where((m) => m.contactId.equals(contactId))
    ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
    ..limit(limit))
    .watch();
}
```

### Lazy Loading

```mermaid
sequenceDiagram
    participant ListView
    participant Controller
    participant Repo
    participant Drift
    
    ListView->>Controller: Scroll to top
    Controller->>Controller: Check if near top
    
    alt Near top
        Controller->>Repo: loadMore(offset)
        Repo->>Drift: Query next batch
        Drift-->>Repo: More messages
        Repo-->>Controller: Append messages
        Controller-->>ListView: Update list
    end
```

## 10. Security (Flutter)

### Encryption Layers

```mermaid
graph TB
    subgraph "Application Layer"
        Message["Plain Text Message"]
    end
    
    subgraph "Flutter WebRTC"
        DTLS["DTLS Encryption<br/>flutter_webrtc"]
    end
    
    subgraph "Flutter MQTT"
        TLS["TLS/WSS<br/>mqtt_client"]
    end
    
    subgraph "Local Storage"
        Encryption["SQLite Encryption<br/>Optional"]
    end
    
    Message --> DTLS
    Message --> TLS
    Message --> Encryption
    
    style DTLS fill:#ef5350
    style TLS fill:#ef5350
    style Encryption fill:#ef5350
```

## Summary

The Flutter implementation provides:

1. **Cross-platform support**: Single codebase for all platforms
2. **Reactive UI**: Riverpod for state management
3. **Type-safe database**: Drift with compile-time SQL verification
4. **Native performance**: Platform-specific optimizations
5. **Robust error handling**: Retry logic with exponential backoff
6. **Offline support**: Local database with sync
7. **Real-time updates**: Stream-based architecture
8. **Polite peer pattern**: Robust WebRTC negotiation

This architecture ensures a consistent, performant, and reliable chat experience across all supported platforms.
