/// Socket configuration for different environments
class SocketConfig {
  static const String _devUrl = 'http://localhost:3000';
  static const String _stagingUrl = 'https://staging-socket.lynkan.com';
  static const String _productionUrl = 'https://socket.lynkan.com';

  /// Get socket URL based on current environment
  static String getSocketUrl(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
      case 'dev':
        return _devUrl;
      case 'staging':
        return _stagingUrl;
      case 'production':
      case 'prod':
        return _productionUrl;
      default:
        return _stagingUrl; // Default to staging
    }
  }

  /// Socket options configuration
  static Map<String, dynamic> getSocketOptions(String? authToken) {
    return {
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
      'timeout': 20000,
      'query': authToken != null ? {'token': authToken} : {},
      'extraHeaders': authToken != null
          ? {
              'Authorization': 'Bearer $authToken',
            }
          : {},
    };
  }

  /// Socket event names
  static const String eventConnect = 'connect';
  static const String eventDisconnect = 'disconnect';
  static const String eventError = 'error';
  static const String eventConnectError = 'connect_error';
  static const String eventReconnect = 'reconnect';
  static const String eventReconnectAttempt = 'reconnect_attempt';
  static const String eventReconnectError = 'reconnect_error';
  static const String eventReconnectFailed = 'reconnect_failed';
  
  // Custom events
  static const String eventNewMessage = 'new_message';
  static const String eventMessageDelivered = 'message_delivered';
  static const String eventMessageRead = 'message_read';
  static const String eventTyping = 'typing';
  static const String eventStopTyping = 'stop_typing';
  static const String eventOnlineStatus = 'online_status';
  static const String eventUserJoined = 'user_joined';
  static const String eventUserLeft = 'user_left';
  static const String eventAuthenticate = 'authenticate';
  static const String eventAuthSuccess = 'auth_success';
  static const String eventAuthError = 'auth_error';
}