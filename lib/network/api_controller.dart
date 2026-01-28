import 'dart:io';
import 'package:dio/dio.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/flavor_assets.dart';
import '../main_common.dart';
import '../services/storage_service.dart';
import 'api_endpoint.dart';
import 'api_response.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class ApiController {
  static ApiController? _instance;
  static ApiController get instance => _instance ??= ApiController._internal();

  factory ApiController() => instance;

  ApiController._internal();

  late Dio _dio;
  String? _authToken;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoint.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7',
        'x-platform-name': FlavorAssets.platformName,
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
        // 'User-Type': 'User',
        'user-type': 'user',

      },
    ));

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }

        // if (options.data is FormData) {
        //   options.headers.remove('Content-Type');
        //   debugPrint(
        //       '[Interceptor] 🔧 Removed Content-Type for FormData request');
        // }

        if (kDebugMode) {
          print('🚀 REQUEST: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          print('Data: ${response.data}');
        }
        handler.next(response);
      },
      /*onError: (error, handler) async {
        if (kDebugMode) {
          print(
              '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Error: ${error.message}');
          if (error.response?.data != null) {
            print('Error Data: ${error.response?.data}');
          }
        }

        if (error.response?.data != null &&
            error.response?.data is Map<String, dynamic>) {
          final errorData = error.response?.data as Map<String, dynamic>;
          final message = errorData['message'];

          if (message == 'Invalid or expired token') {
            final context = navigatorKey.currentContext;
            if (context != null) {
              SnackBarService.showError(
                  'Session expired. Please log in again.');

              ApiService.logout(context);
            }

            return;
          }
        }

        handler.next(error);
      },*/
      onError: (error, handler) async {
        if (kDebugMode) {
          print(
              '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Error: ${error.message}');
          if (error.response?.data != null) {
            print('Error Data: ${error.response?.data}');
          }
        }

        // Check if response contains error data
        if (error.response?.data != null &&
            error.response?.data is Map<String, dynamic>) {
          final errorData = error.response?.data as Map<String, dynamic>;
          final message = errorData['message'];

          // Handle invalid/expired token OR deleted user
          if (message == 'Invalid or expired token' ||
              message == 'User not found' ||
              message == 'User has been deleted' ||
              message == 'Account not found') {
            final context = navigatorKey.currentContext;
            if (context != null) {
              // Show appropriate message based on error type
              if (message == 'Invalid or expired token') {
                SnackBarService.showError(
                    'Session expired. Please log in again.');
              } else {
                SnackBarService.showError(
                    'Your account is no longer active. Please contact support.');
              }

              ApiService.logout(context);
            }

            // Don't pass the error further - we've handled it
            return;
          }
        }

        // For all other errors, continue normal error handling
        handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

/*
  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (_authToken != null) {
        options.headers['Authorization'] = 'Bearer $_authToken';
      }

      if (options.data is FormData) {
        options.headers.remove('Content-Type');
        debugPrint(
            '[Interceptor] 🔧 Removed Content-Type for FormData request');
      }

      if (kDebugMode) {
        print('🚀 REQUEST: ${options.method} ${options.path}');
        print('Headers: ${options.headers}');
        if (options.data != null) {
          print('Data: ${options.data}');
        }
      }

      handler.next(options);
    }, onResponse: (response, handler) {
      if (kDebugMode) {
        print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        print('Data: ${response.data}');
      }
      handler.next(response);
    }, onError: (error, handler) async {
      if (kDebugMode) {
        print(
            '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
        print('Error: ${error.message}');
        if (error.response?.data != null) {
          print('Error Data: ${error.response?.data}');
        }
      }

      handler.next(error);
    }));

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }
*/

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Unexpected error occurred',
      );
    }
  }

//*********************//

  /*Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters
  }) async {
    try {
      debugPrint('[Dio] 🔧 Building FormData...');
      FormData formData = FormData();

      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is PlatformFile && value.path != null) {
          debugPrint('[Dio] 📎 File field: $key → ${value.name}');

          // ✅ Additional file validation
          final file = File(value.path!);
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint(
                '[Dio] 📁 File exists: ${value.path}, size: $fileSize bytes');

            final mimeType = lookupMimeType(value.path!);
            final mediaType = mimeType != null
                ? DioMediaType.parse(mimeType)
                : DioMediaType('application', 'octet-stream');

            formData.files.add(MapEntry(
              key,
              await MultipartFile.fromFile(
                value.path!,
                filename: value.name,
                contentType: mediaType,
              ),
            ));
          } else {
            debugPrint('[Dio] ❌ File does not exist: ${value.path}');
            return ApiResponse.error('File not found',
                message: 'File ${value.name} does not exist');
          }
        } else {
          debugPrint('[Dio] 📝 Field: $key → $value');
          formData.fields.add(MapEntry(key, value.toString()));
        }
      }

      debugPrint('[Dio] 🚀 POST $endpoint');
      debugPrint('[Dio] FormData Fields: ${formData.fields}');
      debugPrint(
          '[Dio] FormData Files: ${formData.files.map((f) => f.key).toList()}');

      final response = await _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StorageService.getToken()}',
            'User-Type': 'User',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      debugPrint('[Dio] ✅ Response: ${response.statusCode} → ${response.data}');
      return ApiResponse.success(response.data,
          statusCode: response.statusCode);
    } on DioException catch (e) {
      debugPrint('[Dio] ❌ DioException Details:');
      debugPrint('[Dio] Type: ${e.type}');
      debugPrint('[Dio] Message: ${e.message}');
      debugPrint('[Dio] Response Status: ${e.response?.statusCode}');
      debugPrint('[Dio] Response Data: ${e.response?.data}');
      debugPrint('[Dio] Request Path: ${e.requestOptions.path}');
      debugPrint('[Dio] Request Method: ${e.requestOptions.method}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return ApiResponse.error(e,
              message:
                  'Connection timeout - please check your internet connection');
        case DioExceptionType.sendTimeout:
          return ApiResponse.error(e,
              message: 'Upload timeout - files might be too large');
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(e, message: 'Server response timeout');
        case DioExceptionType.badResponse:
          return ApiResponse.error(e,
              message: 'Server error: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          return ApiResponse.error(e, message: 'Request was cancelled');
        case DioExceptionType.connectionError:
          return ApiResponse.error(e, message: 'Network connection error');
        case DioExceptionType.unknown:
          return ApiResponse.error(e,
              message: 'Unknown network error - check internet connection');
        default:
          return ApiResponse.error(e, message: 'Network error occurred');
      }
    } catch (e) {
      debugPrint('[Dio] ❌ Unexpected error: $e');
      debugPrint('[Dio] Error type: ${e.runtimeType}');
      return ApiResponse.error(e,
          message: 'Unexpected error occurred: ${e.toString()}');
    }
  }*/

  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('='.padRight(80, '='));
      debugPrint('🚀 MULTIPART REQUEST DEBUG INFO');
      debugPrint('='.padRight(80, '='));
      debugPrint('[Dio] 🔧 Building FormData...');
      FormData formData = FormData();

      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is PlatformFile && value.path != null) {
          debugPrint('[Dio] 📎 File field: $key → ${value.name}');

          final file = File(value.path!);
          if (!await file.exists()) {
            debugPrint('[Dio] ❌ File does not exist: ${value.path}');
            return ApiResponse.error('File not found',
                message: 'File ${value.name} does not exist');
          }

          final fileSize = await file.length();
          debugPrint(
              '[Dio] 📁 File exists: ${value.path}, size: $fileSize bytes');

          final bytes = await file.readAsBytes();
          debugPrint('[Dio] 📊 Read ${bytes.length} bytes from file');

          final mimeType = lookupMimeType(value.path!);
          debugPrint('[Dio] 🎭 MIME type: $mimeType');

          final mediaType = mimeType != null
              ? DioMediaType.parse(mimeType)
              : DioMediaType('image', 'jpeg');

          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: value.name,
            contentType: mediaType,
          );

          debugPrint('[Dio] 📦 MultipartFile created:');
          debugPrint('[Dio]    - filename: ${multipartFile.filename}');
          debugPrint('[Dio]    - length: ${multipartFile.length}');
          debugPrint('[Dio]    - contentType: ${multipartFile.contentType}');

          formData.files.add(MapEntry(key, multipartFile));
          debugPrint('[Dio] ✅ Added file to FormData: $key');
        } else {
          debugPrint('[Dio] 📝 Field: $key → $value');
          formData.fields.add(MapEntry(key, value.toString()));
        }
      }

      debugPrint('');
      debugPrint('📋 COMPLETE REQUEST DETAILS FOR BACKEND DEV:');
      debugPrint('-'.padRight(80, '-'));
      debugPrint('🔗 Endpoint: $endpoint');
      debugPrint('🔗 Full URL: ${ApiEndpoint.baseUrl}$endpoint');
      debugPrint('');

      // Print headers that will be sent
      final headers = {
        'Authorization': 'Bearer ${StorageService.getToken()}',
        'User-Type': 'User',
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7',
        'x-platform-name': FlavorAssets.platformName,
      };

      debugPrint('📤 REQUEST HEADERS:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('  $key: Bearer <token_hidden>');
        } else {
          debugPrint('  $key: $value');
        }
      });
      debugPrint('');

      debugPrint('📦 REQUEST BODY (FormData):');
      debugPrint('  Total Fields: ${formData.fields.length}');
      for (var field in formData.fields) {
        debugPrint('  - Field Name: "${field.key}"');
        debugPrint('    Field Value: "${field.value}"');
        debugPrint('    Value Type: ${field.value.runtimeType}');
      }
      debugPrint('');

      debugPrint('  Total Files: ${formData.files.length}');
      for (var file in formData.files) {
        debugPrint('  - File Field Name: "${file.key}"');
        debugPrint('    Filename: "${file.value.filename}"');
        debugPrint(
            '    File Size: ${file.value.length} bytes (${(file.value.length / 1024).toStringAsFixed(2)} KB)');
        debugPrint('    Content-Type: ${file.value.contentType}');
        debugPrint('    Has Data: ${file.value.length > 0 ? "YES" : "NO"}');
      }
      debugPrint('');

      // Print exact curl command equivalent
      debugPrint('📋 EQUIVALENT CURL COMMAND:');
      String curlCommand =
          'curl -X POST "${ApiEndpoint.baseUrl}$endpoint" \\\n';
      curlCommand += '  -H "Authorization: Bearer <YOUR_TOKEN>" \\\n';
      curlCommand += '  -H "User-Type: User" \\\n';
      for (var field in formData.fields) {
        curlCommand += '  -F "${field.key}=${field.value}" \\\n';
      }
      for (var file in formData.files) {
        curlCommand += '  -F "${file.key}=@${file.value.filename}" \\\n';
      }
      debugPrint(curlCommand.trimRight());
      debugPrint('');

      debugPrint('🔍 BACKEND SHOULD EXPECT:');
      debugPrint('  - Content-Type: multipart/form-data');
      debugPrint(
          '  - Fields in req.body: ${formData.fields.map((f) => f.key).toList()}');
      debugPrint(
          '  - Files in req.files: ${formData.files.map((f) => f.key).toList()}');
      debugPrint('  - req.files structure should be:');
      for (var file in formData.files) {
        debugPrint(
            '    req.files["${file.key}"][0].buffer should contain ${file.value.length} bytes');
      }
      debugPrint('='.padRight(80, '='));
      debugPrint('');

      final response = await _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StorageService.getToken()}',
            'User-Type': 'User',
          },
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
          validateStatus: (status) {
            debugPrint('[Dio] 📡 Response status: $status');
            return status! < 500;
          },
        ),
      );

      debugPrint('');
      debugPrint('='.padRight(80, '='));
      debugPrint('📥 RESPONSE FROM BACKEND:');
      debugPrint('='.padRight(80, '='));
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers.map}');
      debugPrint('Response Body: ${response.data}');
      debugPrint('='.padRight(80, '='));
      debugPrint('');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data,
            statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          response.data,
          message: response.data?['message'] ?? 'Upload failed',
        );
      }
    } on DioException catch (e) {
      debugPrint('');
      debugPrint('='.padRight(80, '='));
      debugPrint('❌ ERROR DETAILS:');
      debugPrint('='.padRight(80, '='));
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Response Status: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('Request Path: ${e.requestOptions.path}');
      debugPrint('Request Headers: ${e.requestOptions.headers}');
      debugPrint('='.padRight(80, '='));
      debugPrint('');

      return ApiResponse.error(e,
          message: e.response?.data?['message'] ?? 'Upload failed');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return ApiResponse.error(e, message: 'Unexpected error: ${e.toString()}');
    }
  }
//****************//

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return ApiResponse.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'File upload failed',
      );
    }
  }

  Future<ApiResponse<String>> downloadFile(
    String endpoint,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
      );

      return ApiResponse.success(
        savePath,
        message: 'File downloaded successfully',
      );
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'File download failed',
      );
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        message = _getErrorMessage(error.response?.data) ??
            'Server error (${error.response?.statusCode})';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown error occurred';
        break;
    }

    return ApiResponse.error(
      error,
      message: message,
      statusCode: statusCode,
    );
  }

  String? _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return data?.toString();
  }

  void dispose() {
    _dio.close();
  }
}
