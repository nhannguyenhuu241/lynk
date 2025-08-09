import 'dart:io';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  // Replace with your actual access token
  const accessToken = 'YOUR_ACCESS_TOKEN_HERE';
  
  final uri = Uri(
    scheme: 'ws',
    host: '35.187.235.34',
    path: '/api/v1/ws/chat',
    queryParameters: {'token': accessToken},
  );
  
  print('Connecting to: $uri');
  
  try {
    final channel = WebSocketChannel.connect(uri);
    
    // Listen to messages from server
    channel.stream.listen(
      (message) {
        print('Received: $message');
        final data = jsonDecode(message);
        
        if (data['type'] == 'chat_response') {
          print('Bot reply: ${data['reply']}');
        }
      },
      onError: (error) => print('Error: $error'),
      onDone: () => print('Connection closed'),
    );
    
    // Send test message
    await Future.delayed(Duration(seconds: 2));
    
    final testMessage = jsonEncode({
      'message': 'Xin chào, bạn khỏe không?'
    });
    
    print('Sending: $testMessage');
    channel.sink.add(testMessage);
    
    // Keep connection alive for testing
    await Future.delayed(Duration(seconds: 10));
    
    // Close connection
    await channel.sink.close();
    print('Test completed');
    
  } catch (e) {
    print('Connection error: $e');
  }
  
  exit(0);
}