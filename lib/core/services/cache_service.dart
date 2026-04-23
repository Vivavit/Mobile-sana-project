import 'package:dio/dio.dart';
import 'package:mobile_camsme_sana_project/core/constants/config.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class CacheService {
  /// Creates a Dio instance with optimized settings
  static Future<Dio> createCachedDio() async {
    final dio = Dio();

    // Set base options with reasonable timeouts
    dio.options = BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile',
      },
    );

    // Add auth interceptor to include token in every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Authorization header if token exists
          if (Session.token != null) {
            options.headers['Authorization'] = 'Bearer ${Session.token}';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized - could trigger logout or token refresh
          if (error.response?.statusCode == 401) {
            debugPrint('Authentication error: Token may be invalid or expired');
          }
          return handler.next(error);
        },
      ),
    );

    // Retry transient failures (common with cold-starting hosted APIs like Render).
    // Only retry safe methods to avoid duplicate writes.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final request = error.requestOptions;
          final method = request.method.toUpperCase();
          final currentRetry = (request.extra['retry_count'] as int?) ?? 0;
          final shouldRetryMethod = method == 'GET' || method == 'HEAD';
          final statusCode = error.response?.statusCode;
          final isTransientStatus = statusCode == 502 || statusCode == 503 || statusCode == 504;
          final isTransientNetworkError =
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout;
          final shouldRetry = shouldRetryMethod &&
              currentRetry < 2 &&
              (isTransientNetworkError || isTransientStatus);

          if (!shouldRetry) {
            return handler.next(error);
          }

          final nextRetry = currentRetry + 1;
          request.extra['retry_count'] = nextRetry;
          final delayMs = 600 * nextRetry;
          await Future.delayed(Duration(milliseconds: delayMs));

          try {
            final cloned = await dio.fetch(request);
            return handler.resolve(cloned);
          } on DioException catch (e) {
            return handler.next(e);
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('DIO Request: ${options.method} ${options.uri}');
            if (options.headers.containsKey('Authorization')) {
              final token = Session.token;
              if (token != null && token.isNotEmpty) {
                final displayToken = token.length > 20 ? '${token.substring(0, 20)}...' : token;
                debugPrint('Auth Header: Bearer $displayToken');
              }
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('DIO Response: ${response.statusCode}');
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('DIO Error: ${error.message}');
            if (error.response != null) {
              debugPrint('Status Code: ${error.response?.statusCode}');
              debugPrint('Response Data: ${error.response?.data}');
            }
            return handler.next(error);
          },
        ),
      );
    }

    return dio;
  }
}
