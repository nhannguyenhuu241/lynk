# WebSocket Debug Guide

## Lỗi hiện tại:
- **401 Unauthorized**: Server trả về "User not found"
- **WebSocket Error**: `{"type": "error", "message": "Unauthorized"}`

## Nguyên nhân có thể:
1. **Token hết hạn**: Token JWT có thể đã expired
2. **User ID không tồn tại**: User ID trong token không match với database
3. **Format token sai**: Token không đúng format mà server yêu cầu

## Cách khắc phục:

### 1. Kiểm tra token:
```dart
// In ChatBloc._initializeWebSocket()
final accessToken = UserProfileService.getAccessToken();
debugPrint('🔑 Full token: $accessToken');

// Decode JWT to check expiry
final parts = accessToken.split('.');
if (parts.length == 3) {
  final payload = json.decode(utf8.decode(base64Url.decode(parts[1])));
  debugPrint('📅 Token payload: $payload');
  
  if (payload['exp'] != null) {
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    debugPrint('⏰ Token expires at: $expiry');
    debugPrint('⏰ Current time: ${DateTime.now()}');
    
    if (DateTime.now().isAfter(expiry)) {
      debugPrint('❌ TOKEN EXPIRED!');
    }
  }
}
```

### 2. Refresh token khi cần:
```dart
// Thêm vào AuthRepository
Future<String?> refreshAccessToken() async {
  // Call refresh token API
  // Save new token
  // Return new token
}
```

### 3. Test WebSocket riêng:
```bash
# Test với curl
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "ws://35.187.235.34/api/v1/ws/chat?token=YOUR_TOKEN"
```

### 4. Kiểm tra server logs:
- Xem server có nhận được token không
- Token có đúng format không
- User ID có tồn tại trong database không

## Giải pháp tạm thời:
1. **Logout và login lại** để lấy token mới
2. **Kiểm tra network** xem có firewall block không
3. **Thử với token hardcode** để test

## Code đã update:
✅ Thêm xử lý auth_error trong WebSocket
✅ Thêm debug log cho token
✅ Thêm handler cho token expired
✅ Format message đúng: `{"message": "content"}`