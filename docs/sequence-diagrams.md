# Sequence Diagrams - Distributed Systems Interactions (Flutter)

## Academic Overview

This document presents sequence diagrams illustrating the temporal interactions between distributed system components in the Flutter P2P chat application. These diagrams demonstrate key distributed systems concepts including asynchronous communication, message passing, consensus protocols, and failure recovery across multiple platforms.

---

## Diagram 1: Cross-Platform System Initialization

### Concept: Platform-Agnostic Distributed Bootstrapping

```mermaid
sequenceDiagram
    participant User
    participant Platform as Platform Layer<br/>(Android/iOS/Web/Desktop)
    participant Flutter as Flutter Framework
    participant Riverpod as Riverpod State
    participant Coord as ChatCoordinator
    participant MQTT as MQTT Service
    participant Drift as Drift Database
    
    Note over User,Drift: Cross-Platform Distributed Bootstrapping
    
    User->>Platform: Launch app
    Platform->>Flutter: Initialize Flutter engine
    
    rect rgb(255, 249, 196)
        Note over Flutter,Riverpod: Phase 1: State Initialization
        Flutter->>Riverpod: Initialize providers
        Riverpod->>Coord: Create ChatCoordinator
        Coord->>MQTT: Initialize MQTT service
        Coord->>Drift: Initialize database
    end
    
    rect rgb(227, 242, 253)
        Note over Coord,MQTT: Phase 2: Connect to Discovery Service
        Coord->>MQTT: connect(userId)
        MQTT->>MQTT: Platform-specific WebSocket
        MQTT-->>Coord: Connected
        MQTT->>MQTT: Subscribe to user/{userId}/*
    end
    
    rect rgb(200, 230, 201)
        Note over Coord,Drift: Phase 3: Load Local State
        Coord->>Drift: Load contacts
        Drift-->>Coord: Stream<List<Contact>>
        Coord->>Drift: Load messages
        Drift-->>Coord: Stream<List<Message>>
    end
    
    rect rgb(255, 224, 178)
        Note over Riverpod,User: Phase 4: Reactive UI Update
        Coord->>Riverpod: Notify state change
        Riverpod->>Flutter: Rebuild widgets
        Flutter->>Platform: Render UI
        Platform-->>User: App ready
    end
    
    Note right of Platform: Distributed Systems Concepts:<br/>• Platform-agnostic initialization<br/>• Reactive state propagation<br/>• Asynchronous bootstrapping<br/>• Stream-based data flow
```

**Distributed Systems Principles**:
- **Platform Independence**: Same distributed logic across platforms
- **Reactive Streams**: Drift streams propagate changes automatically
- **Asynchronous Operations**: Non-blocking initialization
- **Service Discovery**: MQTT topic subscription

---

## Diagram 2: Peer Discovery with Riverpod State Management

### Concept: Reactive Distributed Peer Discovery

```mermaid
sequenceDiagram
    participant UserA
    participant WidgetA as Flutter Widget A
    participant ProviderA as Riverpod Provider A
    participant CoordA as ChatCoordinator A
    participant MQTT_A as MQTT Service A
    participant Broker as MQTT Broker
    participant MQTT_B as MQTT Service B
    participant CoordB as ChatCoordinator B
    participant ProviderB as Riverpod Provider B
    participant WidgetB as Flutter Widget B
    participant UserB
    
    Note over UserA,UserB: Reactive Distributed Peer Discovery
    
    rect rgb(255, 249, 196)
        Note over UserA,CoordA: Initiator Side (Peer A)
        UserA->>WidgetA: Tap "Add Contact"
        WidgetA->>ProviderA: ref.read(coordinator).addContact()
        ProviderA->>CoordA: addContact(peerB_id, name)
        CoordA->>CoordA: Create contact request
        CoordA->>MQTT_A: sendSignalingMessage()
        MQTT_A->>Broker: PUBLISH user/peerB/contactRequest
    end
    
    rect rgb(255, 224, 178)
        Note over Broker: Message Routing (O(1) lookup)
        Broker->>Broker: Route to subscribers
    end
    
    rect rgb(227, 242, 253)
        Note over MQTT_B,UserB: Receiver Side (Peer B)
        Broker->>MQTT_B: FORWARD contactRequest
        MQTT_B->>CoordB: onSignalingMessage()
        CoordB->>CoordB: Validate message
        CoordB->>ProviderB: Notify state change
        ProviderB->>WidgetB: Rebuild widget
        WidgetB-->>UserB: Show contact request dialog
    end
    
    Note right of ProviderB: Distributed Systems Concepts:<br/>• Publish-subscribe decoupling<br/>• Reactive state propagation<br/>• Asynchronous messaging<br/>• Platform-agnostic UI updates
```

**Distributed Systems Principles**:
- **Reactive Programming**: State changes trigger UI updates automatically
- **Publish-Subscribe**: Broker routes messages to subscribers
- **Loose Coupling**: Peers don't need direct addresses
- **Cross-Platform**: Same logic on all platforms

---

## Diagram 3: WebRTC Connection with Platform Channels

### Concept: Cross-Platform P2P Connection Establishment

```mermaid
sequenceDiagram
    participant PeerA as Peer A<br/>(Flutter)
    participant NativeA as Native Layer A<br/>(Platform-specific)
    participant SignalA as MQTT Signaling
    participant Broker as MQTT Broker
    participant SignalB as MQTT Signaling
    participant NativeB as Native Layer B<br/>(Platform-specific)
    participant PeerB as Peer B<br/>(Flutter)
    
    Note over PeerA,PeerB: Cross-Platform WebRTC Negotiation
    
    rect rgb(255, 249, 196)
        Note over PeerA,NativeA: Phase 1: Offer Creation
        PeerA->>NativeA: createOffer() via Method Channel
        NativeA->>NativeA: Platform WebRTC: createOffer()
        NativeA-->>PeerA: SDP offer
        PeerA->>PeerA: setLocalDescription(offer)
        PeerA->>SignalA: Send offer
        SignalA->>Broker: PUBLISH user/peerB/offer
    end
    
    rect rgb(255, 224, 178)
        Note over Broker: Reliable Delivery (QoS 1)
        Broker->>SignalB: FORWARD offer (with ACK)
    end
    
    rect rgb(227, 242, 253)
        Note over SignalB,PeerB: Phase 2: Answer Creation
        SignalB->>PeerB: Deliver offer
        PeerB->>PeerB: setRemoteDescription(offer)
        PeerB->>NativeB: createAnswer() via Method Channel
        NativeB->>NativeB: Platform WebRTC: createAnswer()
        NativeB-->>PeerB: SDP answer
        PeerB->>PeerB: setLocalDescription(answer)
        PeerB->>SignalB: Send answer
        SignalB->>Broker: PUBLISH user/peerA/answer
    end
    
    rect rgb(200, 230, 201)
        Note over Broker,PeerA: Phase 3: Answer Delivery
        Broker->>SignalA: FORWARD answer
        SignalA->>PeerA: Deliver answer
        PeerA->>PeerA: setRemoteDescription(answer)
    end
    
    rect rgb(255, 249, 196)
        Note over PeerA,PeerB: Phase 4: ICE Candidate Exchange
        
        par ICE Gathering (Parallel)
            PeerA->>NativeA: Gather ICE candidates
            NativeA-->>PeerA: ICE candidates
            PeerA->>Broker: PUBLISH candidates
            Broker->>PeerB: FORWARD candidates
            PeerB->>NativeB: addIceCandidate()
        and
            PeerB->>NativeB: Gather ICE candidates
            NativeB-->>PeerB: ICE candidates
            PeerB->>Broker: PUBLISH candidates
            Broker->>PeerA: FORWARD candidates
            PeerA->>NativeA: addIceCandidate()
        end
    end
    
    rect rgb(200, 230, 201)
        Note over PeerA,PeerB: Phase 5: Direct P2P Connection
        NativeA<->>NativeB: WebRTC Connection Established
        NativeA->>PeerA: onConnectionStateChange(connected)
        NativeB->>PeerB: onConnectionStateChange(connected)
    end
    
    Note right of NativeB: Distributed Systems Concepts:<br/>• Platform abstraction<br/>• Two-phase protocol<br/>• Reliable signaling<br/>• Cross-platform WebRTC
```

**Distributed Systems Principles**:
- **Platform Abstraction**: Method channels hide platform differences
- **Two-Phase Protocol**: Offer/answer handshake
- **Reliable Messaging**: QoS 1 guarantees delivery
- **Native Performance**: Platform-specific WebRTC implementation

---

## Diagram 4: Message Transmission with Drift Streams

### Concept: Reactive P2P Data Transfer with Type-Safe Database

```mermaid
sequenceDiagram
    participant UserA
    participant WidgetA as Flutter Widget A
    participant ProviderA as Riverpod Provider A
    participant CoordA as ChatCoordinator A
    participant DriftA as Drift Database A
    participant WebRTC as WebRTC Channel
    participant DriftB as Drift Database B
    participant CoordB as ChatCoordinator B
    participant ProviderB as Riverpod Provider B
    participant WidgetB as Flutter Widget B
    participant UserB
    
    Note over UserA,UserB: Reactive Distributed Message Delivery
    
    rect rgb(255, 249, 196)
        Note over UserA,DriftA: Phase 1: Local Processing (Peer A)
        UserA->>WidgetA: Type message "Hello"
        WidgetA->>ProviderA: ref.read(coordinator).sendMessage()
        ProviderA->>CoordA: sendMessage("Hello")
        CoordA->>CoordA: Create Message object
        CoordA->>DriftA: insert message (status: pending)
        DriftA->>DriftA: SQL INSERT with type safety
        DriftA-->>ProviderA: Stream emits update
        ProviderA->>WidgetA: Rebuild with new message
        WidgetA-->>UserA: Show message (sending...)
    end
    
    rect rgb(255, 224, 178)
        Note over CoordA,WebRTC: Phase 2: P2P Transmission
        CoordA->>WebRTC: Send via DTLS/SCTP
        Note over WebRTC: Direct P2P<br/>No broker<br/>Low latency
    end
    
    rect rgb(227, 242, 253)
        Note over WebRTC,UserB: Phase 3: Remote Processing (Peer B)
        WebRTC->>CoordB: onMessage("Hello")
        CoordB->>CoordB: Validate message
        CoordB->>DriftB: insert message
        DriftB->>DriftB: SQL INSERT with type safety
        DriftB-->>ProviderB: Stream emits update
        ProviderB->>WidgetB: Rebuild with new message
        WidgetB-->>UserB: Display "Hello"
    end
    
    rect rgb(200, 230, 201)
        Note over CoordB,UserA: Phase 4: Acknowledgment
        CoordB->>WebRTC: Send ACK
        WebRTC->>CoordA: Deliver ACK
        CoordA->>DriftA: update status: delivered
        DriftA-->>ProviderA: Stream emits update
        ProviderA->>WidgetA: Rebuild
        WidgetA-->>UserA: Show checkmark
    end
    
    Note right of DriftB: Distributed Systems Concepts:<br/>• Reactive streams<br/>• Type-safe database<br/>• Eventually consistent<br/>• Local-first architecture
```

**Distributed Systems Principles**:
- **Reactive Streams**: Drift streams automatically update UI
- **Type Safety**: Compile-time SQL verification
- **Local-First**: Save locally before transmission
- **Eventually Consistent**: Both databases converge

---

## Diagram 5: Platform-Aware Failure Recovery

### Concept: Cross-Platform Fault Tolerance

```mermaid
sequenceDiagram
    participant Platform as Platform Layer
    participant Flutter as Flutter App
    participant Coord as ChatCoordinator
    participant WebRTC as WebRTC Service
    participant Retry as Retry Manager
    participant MQTT as MQTT Service
    participant Drift as Drift Database
    
    Note over Platform,Drift: Cross-Platform Failure Handling
    
    rect rgb(255, 205, 210)
        Note over Platform: Platform-Specific Event
        Platform->>Flutter: Network change detected
        Flutter->>Coord: onNetworkChange()
        Coord->>WebRTC: Check connection state
        WebRTC-->>Coord: Connection failed
        Coord->>Coord: Detect failure
    end
    
    rect rgb(255, 249, 196)
        Note over Coord,Retry: Exponential Backoff Algorithm
        Coord->>Retry: Start retry sequence
        Coord->>Drift: Queue pending messages
        
        loop Retry Attempts (max 5)
            Retry->>Retry: Calculate delay: 2^attempt seconds
            Note over Retry: Attempt 1: wait 1s
            
            alt MQTT Disconnected
                Retry->>MQTT: Reconnect MQTT first
                MQTT->>MQTT: Platform-specific reconnection
                MQTT-->>Retry: MQTT connected
            end
            
            Retry->>WebRTC: Close old connection
            Retry->>WebRTC: Create new offer
            WebRTC-->>Retry: New SDP offer
            Retry->>MQTT: Send offer via signaling
            
            alt Connection Successful
                WebRTC->>Coord: Connection established
                Coord->>Drift: Flush queued messages
                Drift-->>Coord: Messages sent
                Coord->>Flutter: Update UI state
                Flutter->>Platform: Render success
            else Connection Failed
                Note over Retry: Attempt 2: wait 2s
                Note over Retry: Attempt 3: wait 4s
                Note over Retry: Continue...
            end
        end
    end
    
    rect rgb(255, 205, 210)
        Note over Retry,Platform: Max Retries Reached
        alt Max Retries Exceeded
            Retry->>Coord: Give up
            Coord->>Flutter: Update UI state: Failed
            Flutter->>Platform: Render error state
        end
    end
    
    Note right of Platform: Distributed Systems Concepts:<br/>• Platform-aware failures<br/>• Exponential backoff<br/>• Automatic recovery<br/>• Message queuing
```

**Distributed Systems Principles**:
- **Platform Awareness**: Handles platform-specific network events
- **Failure Detection**: Multiple detection mechanisms
- **Exponential Backoff**: Prevents network flooding
- **Message Queuing**: Ensures eventual delivery

---

## Diagram 6: Polite Peer Pattern (Platform-Independent Consensus)

### Concept: Distributed Consensus Across Platforms

```mermaid
sequenceDiagram
    participant PeerA as Peer A<br/>(Android)
    participant PeerB as Peer B<br/>(iOS)
    
    Note over PeerA,PeerB: Cross-Platform Glare Resolution
    
    rect rgb(255, 249, 196)
        Note over PeerA,PeerB: Phase 1: Simultaneous Offers
        
        par Both create offers
            PeerA->>PeerA: createOffer() on Android
            PeerA->>PeerA: setLocalDescription(offer_A)
        and
            PeerB->>PeerB: createOffer() on iOS
            PeerB->>PeerB: setLocalDescription(offer_B)
        end
        
        par Exchange offers
            PeerA->>PeerB: Send offer_A
        and
            PeerB->>PeerA: Send offer_B
        end
    end
    
    rect rgb(255, 205, 210)
        Note over PeerA,PeerB: Phase 2: Glare Detection
        
        PeerA->>PeerA: Receive offer_B (unexpected)
        PeerA->>PeerA: GLARE DETECTED!
        
        PeerB->>PeerB: Receive offer_A (unexpected)
        PeerB->>PeerB: GLARE DETECTED!
    end
    
    rect rgb(200, 230, 201)
        Note over PeerA,PeerB: Phase 3: Platform-Independent Resolution
        
        PeerA->>PeerA: Compare: "alice" < "bob"
        PeerA->>PeerA: Role: POLITE (lower ID)
        PeerA->>PeerA: rollback() on Android
        PeerA->>PeerA: setRemoteDescription(offer_B)
        PeerA->>PeerA: createAnswer()
        PeerA->>PeerB: Send answer_A
        
        PeerB->>PeerB: Compare: "bob" > "alice"
        PeerB->>PeerB: Role: IMPOLITE (higher ID)
        PeerB->>PeerB: Ignore offer_A on iOS
        PeerB->>PeerB: Wait for answer
        PeerB->>PeerB: Receive answer_A
        PeerB->>PeerB: setRemoteDescription(answer_A)
    end
    
    rect rgb(227, 242, 253)
        Note over PeerA,PeerB: Phase 4: Cross-Platform Connection
        PeerA<->>PeerB: Android ↔ iOS connection established
    end
    
    Note right of PeerB: Distributed Systems Concepts:<br/>• Platform-independent consensus<br/>• Deterministic algorithm<br/>• No central coordinator<br/>• Cross-platform compatibility
```

**Distributed Systems Principles**:
- **Platform Independence**: Same algorithm on Android and iOS
- **Distributed Consensus**: No coordinator needed
- **Deterministic**: Same inputs → same outcome
- **Cross-Platform**: Works between any platform combination

---

## Diagram 7: Drift Reactive Querying During Network Partition

### Concept: Type-Safe Eventual Consistency

```mermaid
sequenceDiagram
    participant User
    participant Widget as Flutter Widget
    participant Provider as Riverpod Provider
    participant Coord as ChatCoordinator
    participant Drift as Drift Database
    participant Network as Network Layer
    
    Note over User,Network: Reactive Offline Operation
    
    rect rgb(200, 230, 201)
        Note over User,Network: Normal Operation
        User->>Widget: Send message 1
        Widget->>Provider: ref.read(coordinator).sendMessage()
        Provider->>Coord: sendMessage()
        Coord->>Drift: insert (status: pending)
        Drift-->>Provider: Stream emits update
        Provider->>Widget: Rebuild
        Coord->>Network: Transmit
        Network-->>Coord: ACK
        Coord->>Drift: update (status: delivered)
        Drift-->>Provider: Stream emits update
        Provider->>Widget: Rebuild with checkmark
    end
    
    rect rgb(255, 205, 210)
        Note over Network: Network Partition Occurs
        Network->>Network: Connection lost
    end
    
    rect rgb(255, 249, 196)
        Note over User,Drift: Offline Mode (Reactive Queuing)
        User->>Widget: Send message 2
        Widget->>Provider: ref.read(coordinator).sendMessage()
        Provider->>Coord: sendMessage()
        Coord->>Drift: insert (status: pending)
        Drift-->>Provider: Stream emits update
        Provider->>Widget: Rebuild (shows queued)
        Coord->>Network: Attempt transmit
        Network-->>Coord: FAILED
        
        User->>Widget: Send message 3
        Widget->>Provider: ref.read(coordinator).sendMessage()
        Provider->>Coord: sendMessage()
        Coord->>Drift: insert (status: pending)
        Drift-->>Provider: Stream emits update
        Provider->>Widget: Rebuild (shows queued)
        Coord->>Network: Attempt transmit
        Network-->>Coord: FAILED
        
        Note over Drift: Type-safe query:<br/>SELECT * WHERE status = 'pending'
    end
    
    rect rgb(227, 242, 253)
        Note over Network: Network Restored
        Network->>Coord: Connection restored
        Coord->>Drift: watchPendingMessages()
        Drift-->>Coord: Stream<List<Message>>
        
        loop For each pending message
            Coord->>Network: Transmit message
            Network-->>Coord: ACK
            Coord->>Drift: update (status: delivered)
            Drift-->>Provider: Stream emits update
            Provider->>Widget: Rebuild incrementally
        end
    end
    
    Note right of Drift: Distributed Systems Concepts:<br/>• Reactive streams<br/>• Type-safe queries<br/>• Partition tolerance<br/>• Eventual consistency
```

**Distributed Systems Principles**:
- **Reactive Streams**: UI updates automatically via Drift streams
- **Type Safety**: Compile-time SQL verification
- **Partition Tolerance**: Works during network split
- **Eventual Consistency**: Messages sync when connected

---

## Diagram 8: Cross-Platform Presence Detection

### Concept: Platform-Aware Liveness Detection

```mermaid
sequenceDiagram
    participant PlatformA as Platform A<br/>(Mobile)
    participant NodeA as Peer A Node
    participant MQTT as MQTT Broker
    participant NodeB as Peer B Node
    participant PlatformB as Platform B<br/>(Desktop)
    
    Note over PlatformA,PlatformB: Cross-Platform Liveness Detection
    
    rect rgb(200, 230, 201)
        Note over PlatformA,NodeA: Mobile App Active
        PlatformA->>NodeA: App in foreground
        NodeA->>NodeA: Start heartbeat timer (30s)
        
        loop Every 30 seconds
            NodeA->>MQTT: PUBLISH presence<br/>{platform: "mobile", status: "online"}
            MQTT->>NodeB: FORWARD presence
            NodeB->>NodeB: Update last_seen
            NodeB->>PlatformB: Update UI
        end
    end
    
    rect rgb(255, 249, 196)
        Note over PlatformA: Mobile App Backgrounded
        PlatformA->>NodeA: App lifecycle: paused
        NodeA->>NodeA: Reduce heartbeat (60s)
        NodeA->>MQTT: PUBLISH presence<br/>{platform: "mobile", status: "away"}
        MQTT->>NodeB: FORWARD presence
        NodeB->>PlatformB: Update UI (away)
    end
    
    rect rgb(255, 205, 210)
        Note over NodeA: Network Issue
        NodeA->>NodeA: Heartbeat fails
        
        Note over NodeB: Timeout Detection
        NodeB->>NodeB: Check last_seen timestamp
        NodeB->>NodeB: Timeout exceeded (120s)
        NodeB->>NodeB: Status: Peer A offline
        NodeB->>PlatformB: Update UI (offline)
    end
    
    rect rgb(227, 242, 253)
        Note over PlatformA: Mobile App Resumed
        PlatformA->>NodeA: App lifecycle: resumed
        NodeA->>NodeA: Resume normal heartbeat (30s)
        NodeA->>MQTT: PUBLISH presence<br/>{platform: "mobile", status: "online"}
        MQTT->>NodeB: FORWARD presence
        NodeB->>NodeB: Update last_seen
        NodeB->>PlatformB: Update UI (online)
    end
    
    Note right of PlatformB: Distributed Systems Concepts:<br/>• Platform-aware heartbeat<br/>• Lifecycle management<br/>• Adaptive intervals<br/>• Soft state
```

**Distributed Systems Principles**:
- **Platform Awareness**: Different heartbeat intervals per platform
- **Lifecycle Management**: Adapts to app state
- **Heartbeat Protocol**: Periodic liveness signals
- **Soft State**: Presence information expires

---

## Summary: Distributed Systems Concepts Illustrated

| Diagram | Primary Concept | Platform-Specific Considerations |
|---------|----------------|----------------------------------|
| **1. Initialization** | Cross-Platform Bootstrapping | Platform-specific WebSocket, storage paths |
| **2. Peer Discovery** | Reactive Publish-Subscribe | Riverpod state propagation |
| **3. Connection Setup** | Platform Abstraction | Method channels, native WebRTC |
| **4. Message Transfer** | Reactive Streams | Drift streams, type-safe queries |
| **5. Failure Recovery** | Platform-Aware Fault Tolerance | Network change detection |
| **6. Glare Resolution** | Platform-Independent Consensus | Works across any platform pair |
| **7. Message Queuing** | Type-Safe Eventual Consistency | Drift reactive queries |
| **8. Presence** | Platform-Aware Liveness | Lifecycle-based heartbeat |

---

## Academic Significance

These sequence diagrams demonstrate:

1. **Cross-Platform Distributed Systems**: Same distributed logic across 6 platforms
2. **Reactive Programming**: Stream-based state propagation
3. **Type Safety**: Compile-time verification of distributed operations
4. **Platform Abstraction**: Hiding platform differences from distributed logic
5. **Asynchronous Communication**: All interactions are non-blocking
6. **Message Passing**: No shared memory, only messages
7. **Distributed Coordination**: Consensus without central authority
8. **Fault Tolerance**: Automatic failure detection and recovery
9. **Eventual Consistency**: Temporary inconsistency for availability
10. **Network Transparency**: Complexity hidden from application

These patterns are fundamental to modern distributed systems and demonstrate how theoretical concepts apply across heterogeneous platforms.
