import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? 'http://localhost:3333';

  final Dio _dio;
  final String _baseUrl;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get<T>('$_baseUrl$path', queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _dio.post<T>('$_baseUrl$path', data: data);
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return _dio.put<T>('$_baseUrl$path', data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>('$_baseUrl$path');
  }
}
