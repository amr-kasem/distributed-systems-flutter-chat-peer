# Component Architecture - Flutter P2P Chat

## System Architecture Overview

```mermaid
graph TB
    subgraph "Presentation Layer (Flutter Widgets)"
        MaterialApp[MaterialApp]
        ChatView[ChatView]
        Sidebar[Sidebar]
        ContactDialog[ContactDialog]
    end
    
    subgraph "State Management (Riverpod)"
        Providers[Riverpod Providers]
        StateNotifiers[StateNotifiers]
    end
    
    subgraph "Coordination Layer"
        Coordinator[ChatCoordinator]
    end
    
    subgraph "Service Layer"
        SignalingSvc[SignalingService]
        WebRTCSvc[WebRtcService]
        ConnMgr[ConnectionManager]
        MsgSvc[MessagingService]
        ContactSvc[ContactService]
    end
    
    subgraph "Repository Layer"
        MsgRepo[MessageRepository]
        ContactRepo[ContactRepository]
    end
    
    subgraph "Infrastructure Layer"
        Drift[(Drift Database<br/>SQLite)]
        MQTT[MQTT Broker]
        WebRTC[WebRTC]
    end
    
    MaterialApp --> ChatView
    MaterialApp --> Sidebar
    MaterialApp --> ContactDialog
    
    ChatView --> Providers
    Sidebar --> Providers
    ContactDialog --> Providers
    
    Providers --> Coordinator
    StateNotifiers --> Coordinator
    
    Coordinator --> SignalingSvc
    Coordinator --> WebRTCSvc
    Coordinator --> ConnMgr
    Coordinator --> MsgSvc
    Coordinator --> ContactSvc
    
    ConnMgr --> SignalingSvc
    ConnMgr --> WebRTCSvc
    MsgSvc --> WebRTCSvc
    MsgSvc --> MsgRepo
    ContactSvc --> ContactRepo
    
    MsgRepo --> Drift
    ContactRepo --> Drift
    SignalingSvc --> MQTT
    WebRTCSvc --> WebRTC
    
    style Coordinator fill:#4fc3f7
    style SignalingSvc fill:#ffb74d
    style WebRTCSvc fill:#81c784
    style Drift fill:#ba68c8
```

## 1. Presentation Layer

### Widget Hierarchy

```mermaid
graph TB
    MaterialApp[MaterialApp<br/>Root Widget]
    
    MaterialApp --> Home[Home Screen]
    
    Home --> Row[Row Layout]
    
    Row --> Sidebar[Sidebar Widget]
    Row --> ChatView[ChatView Widget]
    
    Sidebar --> UserInfo[User Info Card]
    Sidebar --> AddButton[Add Contact Button]
    Sidebar --> ContactList[Contact ListView]
    
    ContactList --> ContactTile1[Contact Tile]
    ContactList --> ContactTile2[Contact Tile]
    ContactList --> ContactTileN[...]
    
    ContactTile1 --> Avatar[CircleAvatar]
    ContactTile1 --> Info[Contact Info]
    ContactTile1 --> Status[Status Indicator]
    
    ChatView --> AppBar[Chat AppBar]
    ChatView --> Messages[Message ListView]
    ChatView --> Input[Input Row]
    
    AppBar --> Title[Contact Name]
    AppBar --> StatusBadge[Connection Status]
    
    Messages --> MessageBubble1[Message Bubble]
    Messages --> MessageBubble2[Message Bubble]
    Messages --> MessageBubbleN[...]
    
    MessageBubble1 --> Content[Text Content]
    MessageBubble1 --> Time[Timestamp]
    MessageBubble1 --> StatusIcon[Status Icon]
    
    Input --> TextField[TextField]
    Input --> SendButton[IconButton]
    
    style MaterialApp fill:#4fc3f7
    style Sidebar fill:#81c784
    style ChatView fill:#ffb74d
```

### ChatView Widget

```dart
class ChatView extends ConsumerStatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Watch providers for reactive updates
    final selectedContact = ref.watch(selectedContactProvider);
    final messages = ref.watch(messagesProvider(selectedContact?.id ?? ''));
    final connectionStatus = ref.watch(connectionStatusProvider);
    
    return Column(
      children: [
        _buildAppBar(selectedContact, connectionStatus),
        Expanded(
          child: _buildMessageList(messages),
        ),
        _buildInputRow(),
      ],
    );
  }
}
```

## 2. State Management (Riverpod)

### Provider Architecture

```mermaid
graph TB
    subgraph "Providers"
        CoordProvider[coordinatorProvider<br/>Provider]
        ContactsProvider[contactsProvider<br/>StreamProvider]
        MessagesProvider[messagesProvider<br/>StreamProvider]
        StatusProvider[connectionStatusProvider<br/>StateProvider]
        SelectedProvider[selectedContactProvider<br/>StateProvider]
    end
    
    subgraph "Services"
        Coordinator[ChatCoordinator]
        ContactRepo[ContactRepository]
        MessageRepo[MessageRepository]
    end
    
    CoordProvider --> Coordinator
    ContactsProvider --> ContactRepo
    MessagesProvider --> MessageRepo
    StatusProvider --> Coordinator
    SelectedProvider --> Coordinator
    
    Coordinator --> ContactRepo
    Coordinator --> MessageRepo
    
    style CoordProvider fill:#4fc3f7
    style ContactsProvider fill:#81c784
    style MessagesProvider fill:#81c784
```

### Provider Definitions

```dart
// Coordinator provider
final coordinatorProvider = Provider<ChatCoordinator>((ref) {
  return ChatCoordinator(
    signalingService: ref.watch(signalingServiceProvider),
    webrtcService: ref.watch(webrtcServiceProvider),
    messageRepository: ref.watch(messageRepositoryProvider),
    contactRepository: ref.watch(contactRepositoryProvider),
    connectionManager: ref.watch(connectionManagerProvider),
    messagingService: ref.watch(messagingServiceProvider),
    contactService: ref.watch(contactServiceProvider),
    userId: ref.watch(userIdProvider),
  );
});

// Contacts stream provider
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.watchAll();
});

// Messages stream provider (family)
final messagesProvider = StreamProvider.family<List<Message>, String>((ref, contactId) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchMessages(contactId);
});

// Connection status provider
final connectionStatusProvider = StateProvider<String>((ref) => 'Disconnected');

// Selected contact provider
final selectedContactProvider = StateProvider<Contact?>((ref) => null);
```

### State Flow

```mermaid
sequenceDiagram
    participant Widget
    participant Provider
    participant Coordinator
    participant Repository
    participant Drift
    
    Note over Widget,Drift: Initial Load
    
    Widget->>Provider: ref.watch(contactsProvider)
    Provider->>Repository: watchAll()
    Repository->>Drift: select().watch()
    Drift-->>Repository: Stream<List<Contact>>
    Repository-->>Provider: Stream
    Provider-->>Widget: AsyncValue<List<Contact>>
    Widget->>Widget: Build UI
    
    Note over Widget,Drift: User Action
    
    Widget->>Provider: ref.read(coordinator).addContact()
    Provider->>Coordinator: addContact()
    Coordinator->>Repository: add(contact)
    Repository->>Drift: insert()
    Drift-->>Repository: Success
    Drift->>Repository: Stream emits update
    Repository->>Provider: New contact list
    Provider->>Widget: Rebuild
```

## 3. Service Layer

### ChatCoordinator

```mermaid
graph TB
    Coordinator[ChatCoordinator]
    
    subgraph "Dependencies (Injected)"
        Signaling[ISignalingService]
        WebRTC[IWebRTCService]
        ConnMgr[IConnectionManager]
        MsgSvc[IMessageService]
        ContactSvc[IContactService]
        MsgRepo[IMessageRepository]
        ContactRepo[IContactRepository]
    end
    
    Coordinator --> Signaling
    Coordinator --> WebRTC
    Coordinator --> ConnMgr
    Coordinator --> MsgSvc
    Coordinator --> ContactSvc
    Coordinator --> MsgRepo
    Coordinator --> ContactRepo
    
    Coordinator --> |Events| UI[UI via Providers]
    
    style Coordinator fill:#4fc3f7
```

**Key Methods:**
```dart
class ChatCoordinator implements IChatCoordinator {
  Future<bool> initialize();
  Future<void> sendMessage(String content);
  Future<void> selectContact(Contact contact);
  Future<bool> addContact(String peerId, String name);
  Future<void> acceptContact(String peerId, String name);
  Future<void> declineContact(String peerId);
  Future<void> removeContact(String peerId);
  Future<void> dispose();
  
  // Event callbacks
  void onMessageReceived(Function(Message) callback);
  void onConnectionStateChange(Function(String) callback);
  void onContactRequest(Function(String from, String name) callback);
  void onContactResponse(Function(String from, bool accepted, String? name) callback);
}
```

### SignalingService (MQTT)

```mermaid
graph TB
    Signaling[SignalingService]
    
    Signaling --> Client[MqttServerClient]
    Signaling --> Queue[Message Queue]
    Signaling --> Reconnect[ReconnectionManager]
    
    Client --> Broker[MQTT Broker]
    Queue --> |flush| Client
    Reconnect --> Client
    
    Signaling --> |callbacks| Coordinator[ChatCoordinator]
    
    style Signaling fill:#ffb74d
```

**Implementation:**
```dart
class SignalingService implements ISignalingService {
  late MqttServerClient _client;
  final String _userId;
  final _logger = Logger();
  
  Future<bool> connect() async {
    _client = MqttServerClient('ws://localhost', '');
    _client.port = 9001;
    _client.websocketProtocols = ['mqtt'];
    _client.keepAlivePeriod = 60;
    
    // Setup callbacks
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    
    await _client.connect();
    return _client.connectionStatus!.state == MqttConnectionState.connected;
  }
  
  Future<void> sendSignalingMessage(SignalingMessage message, String targetId) async {
    final topic = 'user/$targetId/${message.type}';
    final payload = jsonEncode(message.toJson());
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
```

### WebRtcService

```mermaid
graph TB
    WebRTC[WebRtcService]
    
    WebRTC --> PC[RTCPeerConnection]
    WebRTC --> DC[RTCDataChannel]
    WebRTC --> ICE[ICE Handler]
    WebRTC --> Buffer[Candidate Buffer]
    
    PC --> Offer[createOffer]
    PC --> Answer[createAnswer]
    PC --> Rollback[rollback]
    PC --> SetRemote[setRemoteDescription]
    
    DC --> Send[sendMessage]
    DC --> Receive[onMessage]
    
    ICE --> Generate[onIceCandidate]
    ICE --> Add[addIceCandidate]
    
    Buffer --> |drain| Add
    
    style WebRTC fill:#81c784
```

**Key Features:**
```dart
class WebRtcService implements IWebRTCService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;
  
  // Polite peer pattern support
  Future<void> rollbackLocalDescription() async {
    await _peerConnection?.setLocalDescription(
      await _peerConnection!.createOffer({'iceRestart': false}),
    );
  }
  
  // ICE candidate buffering
  Future<void> addIceCandidate(dynamic candidate) async {
    if (!_remoteDescriptionSet) {
      _pendingCandidates.add(RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ));
      return;
    }
    
    await _peerConnection?.addCandidate(RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid'],
      candidate['sdpMLineIndex'],
    ));
  }
  
  // Drain buffered candidates
  Future<void> _drainPendingCandidates() async {
    for (final candidate in _pendingCandidates) {
      await _peerConnection?.addCandidate(candidate);
    }
    _pendingCandidates.clear();
  }
}
```

## 4. Repository Layer

### MessageRepository

```mermaid
graph TB
    MsgRepo[MessageRepository]
    
    MsgRepo --> Save[saveMessage]
    MsgRepo --> Get[getMessages]
    MsgRepo --> Watch[watchMessages]
    MsgRepo --> Update[updateMessageStatus]
    MsgRepo --> Pending[getPendingMessages]
    
    Save --> Drift[Drift Database]
    Get --> Drift
    Watch --> Drift
    Update --> Drift
    Pending --> Drift
    
    Drift --> Stream[Stream<List<Message>>]
    Stream --> Provider[Riverpod Provider]
    Provider --> Widget[Flutter Widget]
    
    style MsgRepo fill:#ba68c8
```

**Implementation:**
```dart
class MessageRepository implements IMessageRepository {
  final AppDatabase _db;
  
  MessageRepository(this._db);
  
  // Save message
  Future<void> saveMessage(
    String userId,
    String contactId,
    models.Message message,
  ) async {
    await _db.into(_db.messages).insert(
      MessagesCompanion.insert(
        id: message.id,
        userId: userId,
        contactId: contactId,
        content: message.content,
        timestamp: message.timestamp,
        isSent: message.isSent,
        status: message.status.toString(),
      ),
    );
  }
  
  // Watch messages (reactive)
  Stream<List<models.Message>> watchMessages(
    String userId,
    String contactId,
  ) {
    return (_db.select(_db.messages)
      ..where((m) => 
        m.userId.equals(userId) & 
        m.contactId.equals(contactId))
      ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
      .watch()
      .map((rows) => rows.map((row) => _toMessage(row)).toList());
  }
  
  // Get pending messages
  Future<List<models.Message>> getPendingMessages(
    String userId,
    String contactId,
  ) async {
    final query = _db.select(_db.messages)
      ..where((m) => 
        m.userId.equals(userId) & 
        m.contactId.equals(contactId) &
        m.status.equals('pending'));
    
    final rows = await query.get();
    return rows.map((row) => _toMessage(row)).toList();
  }
}
```

### ContactRepository

```mermaid
graph TB
    ContactRepo[ContactRepository]
    
    ContactRepo --> GetAll[getAll]
    ContactRepo --> Get[get]
    ContactRepo --> Add[add]
    ContactRepo --> Update[update]
    ContactRepo --> Delete[softDelete]
    ContactRepo --> Watch[watchAll]
    
    GetAll --> Drift[Drift Database]
    Get --> Drift
    Add --> Drift
    Update --> Drift
    Delete --> Drift
    Watch --> Drift
    
    Drift --> Stream[Stream<List<Contact>>]
    Stream --> Provider[Riverpod Provider]
    Provider --> Widget[Flutter Widget]
    
    style ContactRepo fill:#ba68c8
```

## 5. Data Flow Examples

### Send Message Flow

```mermaid
sequenceDiagram
    participant Widget
    participant Provider
    participant Coord
    participant MsgSvc
    participant WebRTC
    participant MsgRepo
    participant Drift
    
    Widget->>Provider: sendMessage(content)
    Provider->>Coord: sendMessage(content)
    Coord->>MsgSvc: sendMessage(content)
    
    MsgSvc->>MsgSvc: Create Message with UUID
    MsgSvc->>MsgRepo: saveMessage(message)
    MsgRepo->>Drift: insert()
    Drift-->>MsgRepo: Saved
    Drift->>Provider: Stream update
    Provider->>Widget: Rebuild with new message
    
    MsgSvc->>WebRTC: sendMessage(content)
    WebRTC->>WebRTC: RTCDataChannelMessage
    WebRTC-->>MsgSvc: Sent
    
    MsgSvc->>MsgRepo: updateStatus(delivered)
    MsgRepo->>Drift: update()
    Drift-->>MsgRepo: Updated
    Drift->>Provider: Stream update
    Provider->>Widget: Rebuild with status
```

### Receive Message Flow

```mermaid
sequenceDiagram
    participant Peer
    participant WebRTC
    participant Coord
    participant MsgRepo
    participant Drift
    participant Provider
    participant Widget
    
    Peer->>WebRTC: Data via channel
    WebRTC->>WebRTC: Parse JSON
    WebRTC->>Coord: onMessage(content)
    Coord->>MsgRepo: saveMessage(message)
    MsgRepo->>Drift: insert()
    Drift-->>MsgRepo: Saved
    Drift->>Provider: Stream update
    Provider->>Widget: Rebuild with new message
    Widget->>Widget: Auto-scroll to bottom
```

## 6. Cross-Platform Architecture

### Platform Channels

```mermaid
graph TB
    subgraph "Dart Layer"
        FlutterApp[Flutter App]
        Services[Services]
    end
    
    subgraph "Platform Channel"
        MethodChannel[MethodChannel]
        EventChannel[EventChannel]
    end
    
    subgraph "Native Layer"
        Android[Android Kotlin/Java]
        iOS[iOS Swift/Obj-C]
        Desktop[Desktop C++]
    end
    
    FlutterApp --> Services
    Services --> MethodChannel
    Services --> EventChannel
    
    MethodChannel --> Android
    MethodChannel --> iOS
    MethodChannel --> Desktop
    
    EventChannel --> Android
    EventChannel --> iOS
    EventChannel --> Desktop
    
    style FlutterApp fill:#4fc3f7
    style Android fill:#81c784
    style iOS fill:#81c784
    style Desktop fill:#81c784
```

## Summary

The Flutter architecture provides:

1. **Reactive UI**: Riverpod providers for automatic rebuilds
2. **Type Safety**: Drift for compile-time SQL verification
3. **Clean Architecture**: Clear separation of concerns
4. **Dependency Injection**: Provider-based DI
5. **Cross-Platform**: Single codebase for all platforms
6. **Testability**: Interface-based design
7. **Performance**: Native compilation
8. **Offline Support**: Local database with sync
