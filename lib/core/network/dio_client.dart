import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pos_system/core/services/shared_preferences_service.dart';
import 'package:pos_system/core/network/api_constants.dart';

class DioClient {
  final Dio _dio;
  final SharedPreferencesService _prefsService;
  
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  DioClient(this._dio, this._prefsService) {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

    // Add Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefsService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // If 401 Unauthorized, try to refresh token
          if (e.response?.statusCode == 401 &&
              e.requestOptions.path != ApiConstants.login &&
              e.requestOptions.path != ApiConstants.refreshToken) {
            
            final currentToken = _prefsService.getToken();
            final failedToken = e.requestOptions.headers['Authorization']
                ?.toString()
                .replaceFirst('Bearer ', '');

            // If the token in storage is already different from the one that failed,
            // it means it was already refreshed by another concurrent request.
            if (currentToken != null && currentToken != failedToken) {
              e.requestOptions.headers['Authorization'] = 'Bearer $currentToken';
              try {
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (retryError) {
                return handler.next(e);
              }
            }

            // If already refreshing, wait for it to complete
            if (_isRefreshing) {
              final newToken = await _refreshCompleter?.future;
              if (newToken != null) {
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final retryResponse = await _dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                } catch (retryError) {
                  return handler.next(e);
                }
              }
              return handler.next(e);
            }

            // Start refresh process
            final newToken = await refreshToken();
            
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (retryError) {
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Add Pretty Dio Logger
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  // Synchronized refresh token method
  Future<String?> refreshToken() async {
    if (_isRefreshing) {
      return await _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final oldToken = _prefsService.getToken();
      if (oldToken == null) {
        _refreshCompleter?.complete(null);
        return null;
      }

      // Use a separate Dio instance for refresh to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));
      
      refreshDio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ));

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $oldToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final newToken = data['token'] as String;
        
        // IMPORTANT: The server might not return user data on refresh.
        // We only save it if it exists.
        if (data.containsKey('user') && data['user'] != null) {
          final userJson = data['user'] as Map<String, dynamic>;
          await _prefsService.saveUser(userJson);
        }

        // Save new token
        await _prefsService.saveToken(newToken);
        
        _refreshCompleter?.complete(newToken);
        return newToken;
      }
      
      _refreshCompleter?.complete(null);
      return null;
    } catch (err) {
      _refreshCompleter?.complete(null);
      // Only clear auth if the server explicitly says the refresh token is invalid
      if (err is DioException && err.response?.statusCode == 401) {
        await _prefsService.clearAuth();
      }
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Response> getPaginated(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    List<dynamic> allItems = [];
    int currentPage = 1;
    int lastPage = 1;

    // Fetch first page to get metadata
    final response = await _dio.get(
      path,
      queryParameters: {
        ...?queryParameters,
        'page': currentPage,
      },
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      // Check if the response follows the Laravel pagination structure
      if (data is Map<String, dynamic> && data.containsKey('last_page') && data.containsKey('data')) {
        allItems.addAll(data['data'] as List);
        lastPage = data['last_page'] as int;

        // Fetch remaining pages sequentially
        for (currentPage = 2; currentPage <= lastPage; currentPage++) {
          final nextResponse = await _dio.get(
            path,
            queryParameters: {
              ...?queryParameters,
              'page': currentPage,
            },
            options: options,
            cancelToken: cancelToken,
          );
          if (nextResponse.statusCode == 200) {
            final nextData = nextResponse.data['data'];
            if (nextData is Map<String, dynamic> && nextData.containsKey('data')) {
              allItems.addAll(nextData['data'] as List);
            }
          }
        }

        // Create a new response object containing all collected items
        // We simulate a single-page response for compatibility
        return Response(
          data: {
            'success': response.data['success'],
            'message': response.data['message'],
            'data': {
              'data': allItems,
              'current_page': 1,
              'last_page': 1,
              'total': allItems.length,
            }
          },
          headers: response.headers,
          requestOptions: response.requestOptions,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
        );
      }
    }

    return response;
  }

  Dio get dio => _dio;
}
