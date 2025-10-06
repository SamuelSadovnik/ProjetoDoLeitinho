import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  String? _authToken;

  ApiService({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          print('MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Auth endpoints
  Future<Response> login(String document, String password) async {
    return await _dio.post(
      '/auth/login',
      data: {'document': document, 'password': password},
    );
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  // Collector endpoints
  Future<Response> getCollections({
    DateTime? startDate,
    DateTime? endDate,
    String? farmId,
  }) async {
    return await _dio.get(
      '/collector/collections',
      queryParameters: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (farmId != null) 'farmId': farmId,
      },
    );
  }

  Future<Response> createCollection(Map<String, dynamic> data) async {
    return await _dio.post('/collector/collections', data: data);
  }

  Future<Response> updateCollection(int id, Map<String, dynamic> data) async {
    return await _dio.put('/collector/collections/$id', data: data);
  }

  Future<Response> getFarms() async {
    return await _dio.get('/collector/farms');
  }

  Future<Response> getProducers() async {
    return await _dio.get('/collector/producers');
  }

  // Producer endpoints
  Future<Response> getProducerCollections({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dio.get(
      '/producer/collections',
      queryParameters: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
    );
  }

  Future<Response> getCollectionById(int id) async {
    return await _dio.get('/producer/collections/$id');
  }

  Future<Response> getStatistics({int? month, int? year}) async {
    return await _dio.get(
      '/producer/statistics',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
  }

  Future<Response> exportPdf({DateTime? startDate, DateTime? endDate}) async {
    return await _dio.get(
      '/producer/export-pdf',
      queryParameters: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      options: Options(responseType: ResponseType.bytes),
    );
  }

  // Generic methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
