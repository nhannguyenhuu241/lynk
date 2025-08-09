import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class BaseApiService {
  static const String baseUrl = 'http://35.187.235.34';
  static const Duration timeout = Duration(seconds: 30);

  static Dio? _dio;

  static Dio get dio {
    _dio ??= createDio();
    return _dio!;
  }

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
          logPrint: (log) => debugPrint(log.toString()),
        ),
      );
    }

    // Add custom curl logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // Generate cURL command
          final curl = _generateCurlCommand(options);
          debugPrint('\n╔══════════════════════════════════════════════════════════');
          debugPrint('║ API REQUEST - ${DateTime.now().toIso8601String()}');
          debugPrint('╠══════════════════════════════════════════════════════════');
          debugPrint('║ cURL Command:');
          debugPrint('║ $curl');
          debugPrint('╚══════════════════════════════════════════════════════════\n');
          handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          debugPrint('\n╔══════════════════════════════════════════════════════════');
          debugPrint('║ API RESPONSE - ${DateTime.now().toIso8601String()}');
          debugPrint('╠══════════════════════════════════════════════════════════');
          debugPrint('║ Status Code: ${response.statusCode}');
          debugPrint('║ Response Data:');
          debugPrint('║ ${response.data}');
          debugPrint('╚══════════════════════════════════════════════════════════\n');
          handler.next(response);
        },
      ),
    );

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          debugPrint('API Error: ${error.message}');
          debugPrint('Status Code: ${error.response?.statusCode}');
          debugPrint('Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static void addAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void removeAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  static String _generateCurlCommand(RequestOptions options) {
    final StringBuffer curl = StringBuffer('curl');
    
    // Add method
    curl.write(' -X ${options.method}');
    
    // Add URL
    final uri = options.uri;
    curl.write(' "$uri"');
    
    // Add headers
    options.headers.forEach((key, value) {
      curl.write(' -H "$key: $value"');
    });
    
    // Add data if present
    if (options.data != null) {
      String jsonData;
      if (options.data is Map || options.data is List) {
        // Convert to proper JSON string
        try {
          jsonData = jsonEncode(options.data);
          // Escape quotes for shell
          jsonData = jsonData.replaceAll('"', '\\"');
        } catch (e) {
          jsonData = options.data.toString();
        }
      } else {
        jsonData = options.data.toString();
      }
      curl.write(' -d "$jsonData"');
    }
    
    return curl.toString();
  }
}