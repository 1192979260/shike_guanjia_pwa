import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.code, this.message, [this.fields]);

  final String code;
  final String message;
  final List<dynamic>? fields;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://localhost:3000',
              ),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'content-type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  final Dio _dio;
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('authorization');
    } else {
      _dio.options.headers['authorization'] = 'Bearer $token';
    }
  }

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: _clean(queryParameters),
    );
    return _unwrap<T>(response.data);
  }

  Future<T> postData<T>(String path, {Map<String, dynamic>? data}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: _clean(data),
    );
    return _unwrap<T>(response.data);
  }

  Future<T> patchData<T>(String path, {Map<String, dynamic>? data}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: _clean(data),
    );
    return _unwrap<T>(response.data);
  }

  Future<T> deleteData<T>(String path) async {
    final response = await _dio.delete<Map<String, dynamic>>(path);
    return _unwrap<T>(response.data);
  }

  Future<String> getText(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<String>(
      path,
      queryParameters: _clean(queryParameters),
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }

  T _unwrap<T>(Map<String, dynamic>? body) {
    if (body == null) {
      throw StateError('Empty API response');
    }
    if (body.containsKey('error')) {
      final error = body['error'] as Map<String, dynamic>?;
      throw ApiException(
        error?['code'] as String? ?? 'API_ERROR',
        error?['message'] as String? ?? 'API request failed',
        error?['fields'] as List<dynamic>?,
      );
    }
    return body['data'] as T;
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? value) {
    if (value == null) return null;
    return Map.fromEntries(value.entries.where((entry) => entry.value != null));
  }
}
