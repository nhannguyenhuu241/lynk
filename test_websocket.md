# WebSocket Integration Test Guide

## WebSocket Endpoint
```
ws://35.187.235.34/api/v1/ws/chat/{{user_id}}?token={{access_token}}
```

## Implementation Summary

### 1. WebSocket Service (`chat_websocket_service.dart`)
- ✅ Configured with correct URL: `35.187.235.34`
- ✅ Path: `/api/v1/ws/chat/{userId}`
- ✅ Query parameter: `token={accessToken}`
- ✅ Auto-reconnection support (5 attempts)
- ✅ Heartbeat mechanism (ping/pong every 30s)

### 2. Chat Service (`chat_service.dart`)
- ✅ Initializes WebSocket with user credentials
- ✅ Handles incoming messages
- ✅ Sends messages via REST API + WebSocket sync
- ✅ Typing indicator support

### 3. Chat Bloc Integration (`chat_bloc.dart`)
- ✅ Auto-connects on chat screen initialization
- ✅ Retrieves `user_id` and `access_token` from UserProfileService
- ✅ Sends messages through WebSocket when connected
- ✅ Handles typing indicators (auto-sends when user types)
- ✅ Receives and displays incoming WebSocket messages

## Features Implemented

1. **Auto-connection**: WebSocket connects automatically when user enters chat screen
2. **Message Sync**: Messages are sent via both REST API and WebSocket for reliability
3. **Typing Indicators**: Automatically sent when user types, stops after 2 seconds of inactivity
4. **Reconnection**: Automatic reconnection with exponential backoff
5. **Heartbeat**: Keeps connection alive with ping/pong messages

## Testing Steps

1. **Login/Register Flow**:
   - Complete registration or login
   - System saves `user_id` and `access_token`

2. **Chat Screen**:
   - Navigate to chat screen
   - Check console for: "✅ WebSocket initialized successfully for user: {userId}"
   - Check connection status: "🔌 WebSocket connection state: Connected"

3. **Send Message**:
   - Type a message
   - Console shows: "📤 Message sent successfully via API/WebSocket"
   - Message appears in chat history

4. **Typing Indicator**:
   - Start typing → sends typing indicator (true)
   - Stop typing for 2 seconds → sends typing indicator (false)

5. **Receive Messages**:
   - When server sends message via WebSocket
   - Console shows: "📨 Received WebSocket message: {text}"
   - Message appears in chat history

## Debug Messages

Look for these in console:
- `✅ WebSocket initialized successfully`
- `🔌 WebSocket connection state: Connected/Disconnected`
- `📤 Message sent successfully via API/WebSocket`
- `📨 Received WebSocket message`
- `Connecting to WebSocket: ws://35.187.235.34/api/v1/ws/chat/{userId}?token={token}`

## Error Handling

- Missing credentials: "⚠️ WebSocket not initialized: Missing user credentials"
- Connection failed: "❌ Failed to initialize WebSocket: {error}"
- Send failed: "❌ Failed to send message: {error}"
- Auto-reconnection on disconnect (max 5 attempts)