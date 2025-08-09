# Socket Manager Implementation Guide

## Overview
Socket Manager provides real-time communication capabilities for the LynkAn chat application using Socket.IO.

## Installation

1. Add socket_io_client dependency to pubspec.yaml:
```yaml
dependencies:
  socket_io_client: ^2.0.3+1
```

2. Run `flutter pub get`

## Architecture

### Core Components

1. **SocketManager** (`socket_manager.dart`)
   - Singleton pattern implementation
   - Handles low-level socket operations
   - Manages connection, reconnection, and events

2. **SocketService** (`socket_service.dart`)
   - High-level wrapper around SocketManager
   - Integrates with app's SharedPreferences
   - Provides simplified APIs for common operations

3. **Models**
   - `SocketMessage`: Message data structure
   - `TypingIndicator`: Typing status
   - `OnlineStatus`: User presence
   - `SocketEvent`: Generic socket events

## Usage

### 1. Initialize Socket Service

```dart
// In your app initialization (e.g., main.dart or splash screen)
final socketService = SocketService();

// Initialize with user credentials
await socketService.initialize();
```

### 2. Listen to Connection State

```dart
socketService.connectionState.listen((isConnected) {
  if (isConnected) {
    print('Socket connected');
  } else {
    print('Socket disconnected');
  }
});
```

### 3. Send Messages

```dart
// Send text message
await socketService.sendTextMessage(
  recipientId: 'recipient-user-id',
  content: 'Hello, World!',
);

// Send image message
await socketService.sendImageMessage(
  recipientId: 'recipient-user-id',
  imageUrl: 'https://example.com/image.jpg',
  caption: 'Check out this image!',
);

// Send file message
await socketService.sendFileMessage(
  recipientId: 'recipient-user-id',
  fileUrl: 'https://example.com/document.pdf',
  fileName: 'document.pdf',
  fileSize: 1024000, // in bytes
  mimeType: 'application/pdf',
);
```

### 4. Handle Incoming Messages

```dart
socketService.messages.listen((message) {
  print('New message from ${message.senderId}: ${message.content}');
  
  // Add to your message list
  // Update UI
  
  // Mark as read if visible
  socketService.markMessageAsRead(message.id);
});
```

### 5. Typing Indicators

```dart
// Send typing indicator
socketService.sendTypingIndicator('recipient-id', true);

// Listen to typing indicators
socketService.typingIndicators.listen((typingMap) {
  typingMap.forEach((userId, indicator) {
    if (indicator.isTyping) {
      print('$userId is typing...');
    }
  });
});
```

### 6. Online Status

```dart
// Update your status
socketService.updateOnlineStatus(true, status: 'available');

// Listen to online statuses
socketService.onlineStatuses.listen((statusMap) {
  statusMap.forEach((userId, status) {
    print('$userId is ${status.isOnline ? "online" : "offline"}');
  });
});
```

### 7. Chat Rooms

```dart
// Join a room
socketService.joinRoom('room-123');

// Leave a room
socketService.leaveRoom('room-123');
```

## Integration Example

```dart
class ChatScreen extends StatefulWidget {
  final String recipientId;
  
  const ChatScreen({Key? key, required this.recipientId}) : super(key: key);
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final List<SocketMessage> _messages = [];
  Timer? _typingTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _setupListeners();
  }
  
  Future<void> _initializeSocket() async {
    await _socketService.initialize();
    _socketService.joinRoom(widget.recipientId);
  }
  
  void _setupListeners() {
    // Listen to messages
    _socketService.messages.listen((message) {
      if (message.senderId == widget.recipientId || 
          message.recipientId == widget.recipientId) {
        setState(() {
          _messages.add(message);
        });
      }
    });
    
    // Listen to typing
    _socketService.typingIndicators.listen((typingMap) {
      setState(() {
        // Update UI based on typing status
      });
    });
    
    // Text controller for typing indicator
    _messageController.addListener(() {
      _typingTimer?.cancel();
      
      if (_messageController.text.isNotEmpty) {
        _socketService.sendTypingIndicator(widget.recipientId, true);
        
        _typingTimer = Timer(const Duration(seconds: 3), () {
          _socketService.sendTypingIndicator(widget.recipientId, false);
        });
      }
    });
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    await _socketService.sendTextMessage(
      recipientId: widget.recipientId,
      content: text,
    );
    
    _messageController.clear();
  }
  
  @override
  void dispose() {
    _typingTimer?.cancel();
    _socketService.leaveRoom(widget.recipientId);
    _messageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Build your chat UI here
    return Container();
  }
}
```

## Environment Configuration

The socket URLs are configured in `socket_config.dart`:

- Development: `http://localhost:3000`
- Staging: `https://staging-socket.lynkan.com`
- Production: `https://socket.lynkan.com`

## Error Handling

Listen to errors:

```dart
socketService.errors.listen((error) {
  print('Socket error: $error');
  // Show error to user
});
```

## Best Practices

1. **Always initialize** socket service after user authentication
2. **Update auth token** when refreshed:
   ```dart
   await socketService.updateAuthToken(newToken);
   ```
3. **Set offline status** before app termination
4. **Join/leave rooms** appropriately to avoid memory leaks
5. **Handle reconnection** gracefully with proper UI feedback
6. **Dispose properly** when done:
   ```dart
   await socketService.dispose();
   ```

## Troubleshooting

1. **Connection Issues**
   - Check network connectivity
   - Verify auth token is valid
   - Ensure socket server URL is correct

2. **Message Not Received**
   - Verify both users are in the same room
   - Check socket connection state
   - Ensure proper event listeners are set up

3. **Typing Indicator Not Working**
   - Check if recipient is online
   - Verify typing events are being sent
   - Ensure proper debouncing is implemented

## Server Requirements

Your socket server should implement these events:
- `authenticate`: For user authentication
- `new_message`: For message broadcasting
- `typing`/`stop_typing`: For typing indicators
- `online_status`: For presence updates
- `join_room`/`leave_room`: For room management
- `message_delivered`/`message_read`: For message status

## Security Considerations

1. Always use WSS (WebSocket Secure) in production
2. Implement proper authentication
3. Validate all incoming data
4. Use room-based isolation for private conversations
5. Implement rate limiting on the server