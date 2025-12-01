import 'package:dio/dio.dart';
import '../models/models.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  String? _authToken;
  UserModel? _currentUser;

  ApiService({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
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
          print('DATA: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          print('RESPONSE DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          print('MESSAGE: ${error.message}');
          print('RESPONSE: ${error.response?.data}');
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
    _currentUser = null;
  }

  UserModel? get currentUser => _currentUser;

  void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  // ==================== AUTH/USERS ENDPOINTS ====================

  /// Busca usuário por documento (CPF/CNPJ) - para login
  Future<Response> getUserByDocument(String document) async {
    // Limpa o documento para buscar
    document.replaceAll(RegExp(r'[^\d]'), '');
    final users = await _dio.get('/users/');
    return users;
  }

  /// Busca todos os usuários
  Future<Response> getAllUsers() async {
    return await _dio.get('/users/');
  }

  /// Busca usuário por ID
  Future<Response> getUserById(int id) async {
    return await _dio.get('/users/$id');
  }

  /// Cria novo usuário
  Future<Response> createUser({
    required String name,
    required String document,
    required String email,
    required String passwordHash,
    required int type,
  }) async {
    return await _dio.post(
      '/users/',
      data: {
        'name': name,
        'document': document,
        'email': email,
        'passwordHash': passwordHash,
        'type': type.toString(),
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  // ==================== ANIMALS ENDPOINTS ====================

  /// Busca todos os animais
  Future<Response> getAllAnimals() async {
    return await _dio.get('/animals/');
  }

  /// Busca animal por ID
  Future<Response> getAnimalById(int id) async {
    return await _dio.get('/animals/$id');
  }

  // ==================== FARMS ENDPOINTS ====================

  /// Busca todas as fazendas
  Future<Response> getAllFarms() async {
    return await _dio.get('/farms/');
  }

  /// Busca fazenda por ID
  Future<Response> getFarmById(int id) async {
    return await _dio.get('/farms/$id');
  }

  /// Gera QR Code da fazenda
  Future<Response> getFarmQrCode(int id) async {
    return await _dio.get('/farms/qrcode/$id');
  }

  /// Cria nova fazenda
  Future<Response> createFarm({
    required String name,
    required int producerId,
  }) async {
    return await _dio.post(
      '/farms/',
      data: {'name': name, 'producerid': producerId.toString()},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  // ==================== COLLECTIONS ENDPOINTS ====================

  /// Busca todas as coletas
  Future<Response> getAllCollections() async {
    return await _dio.get('/collections/');
  }

  /// Busca coleta por ID
  Future<Response> getCollectionById(int id) async {
    return await _dio.get('/collections/$id');
  }

  /// Cria nova coleta
  Future<Response> createCollection({
    required int farmId,
    required int producerId,
    required int collectorId,
    required int animalId,
    required double quantity,
    required double temperature,
    required double acidity,
    required bool producerPresent,
    String? observations,
    required DateTime collectionDate,
  }) async {
    // Formato esperado pelo backend: dd/MM/yyyy HH:mm:ss
    final dateString =
        '${collectionDate.day.toString().padLeft(2, '0')}/${collectionDate.month.toString().padLeft(2, '0')}/${collectionDate.year} ${collectionDate.hour.toString().padLeft(2, '0')}:${collectionDate.minute.toString().padLeft(2, '0')}:${collectionDate.second.toString().padLeft(2, '0')}';

    return await _dio.post(
      '/collections/',
      data: {
        'animalid': animalId.toString(),
        'farmid': farmId.toString(),
        'producerid': producerId.toString(),
        'collectorid': collectorId.toString(),
        'quantity': quantity.toString(),
        'temperature': temperature.toString(),
        'acidity': acidity.toString(),
        'producerPresent': producerPresent.toString(),
        'observations': observations ?? '',
        'collectionDate': dateString,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  /// Atualiza coleta existente
  Future<Response> updateCollection({
    required int idCollection,
    required int farmId,
    required int producerId,
    required int collectorId,
    required int animalId,
    required double quantity,
    required double temperature,
    required double acidity,
    required bool producerPresent,
    String? observations,
    required DateTime collectionDate,
  }) async {
    // Formato esperado pelo backend: dd/MM/yyyy HH:mm:ss
    final dateString =
        '${collectionDate.day.toString().padLeft(2, '0')}/${collectionDate.month.toString().padLeft(2, '0')}/${collectionDate.year} ${collectionDate.hour.toString().padLeft(2, '0')}:${collectionDate.minute.toString().padLeft(2, '0')}:${collectionDate.second.toString().padLeft(2, '0')}';

    return await _dio.patch(
      '/collections/',
      data: {
        'idcollection': idCollection.toString(),
        'animalid': animalId.toString(),
        'farmid': farmId.toString(),
        'producerid': producerId.toString(),
        'collectorid': collectorId.toString(),
        'quantity': quantity.toString(),
        'temperature': temperature.toString(),
        'acidity': acidity.toString(),
        'producerPresent': producerPresent.toString(),
        'observations': observations ?? '',
        'collectionDate': dateString,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  // ==================== PRODUCER ENDPOINTS ====================

  /// Busca coletas do produtor
  Future<Response> getProducerCollections(int producerId) async {
    return await _dio.get('/producers/$producerId/collections/');
  }

  /// Busca estatísticas do produtor
  Future<Response> getProducerStats({
    required int producerId,
    int? year,
    int? month,
  }) async {
    final queryParams = <String, dynamic>{'producerid': producerId.toString()};
    if (year != null) queryParams['year'] = year.toString();
    if (month != null) queryParams['month'] = month.toString();

    return await _dio.get('/producers/stats/', queryParameters: queryParams);
  }

  // ==================== COLLECTOR ENDPOINTS ====================

  /// Busca histórico de coletas do coletor
  Future<Response> getCollectorHistory({
    required int collectorId,
    int? farmId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (farmId != null) queryParams['farmid'] = farmId.toString();
    if (startDate != null) {
      // Formato esperado pelo backend: dd/MM/yyyy
      queryParams['startDate'] =
          '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    }
    if (endDate != null) {
      // Formato esperado pelo backend: dd/MM/yyyy
      queryParams['endDate'] =
          '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    }
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _dio.get(
      '/collectors/$collectorId/collections/history/',
      queryParameters: queryParams,
    );
  }

  /// Busca estatísticas do coletor
  Future<Response> getCollectorStats(int producerId) async {
    return await _dio.get(
      '/collectors/stats/',
      queryParameters: {'producerid': producerId.toString()},
    );
  }

  // ==================== GENERIC METHODS ====================

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
