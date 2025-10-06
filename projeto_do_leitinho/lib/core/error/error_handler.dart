import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Failure) {
      return error;
    } else {
      return ServerFailure('Erro inesperado: ${error.toString()}');
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Tempo de conexão esgotado. Verifique sua internet.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Falha na conexão. Verifique sua internet.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const NetworkFailure('Requisição cancelada.');

      default:
        return const NetworkFailure('Erro de rede desconhecido.');
    }
  }

  static Failure _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerFailure('Resposta do servidor inválida.');
    }

    switch (response.statusCode) {
      case 400:
        return ValidationFailure(_extractErrorMessage(response));
      case 401:
        return const AuthenticationFailure(
          'Não autenticado. Faça login novamente.',
        );
      case 403:
        return const AuthenticationFailure('Acesso negado.');
      case 404:
        return const ServerFailure('Recurso não encontrado.');
      case 422:
        return ValidationFailure(_extractErrorMessage(response));
      case 500:
      case 502:
      case 503:
        return const ServerFailure(
          'Erro no servidor. Tente novamente mais tarde.',
        );
      default:
        return ServerFailure(
          'Erro ${response.statusCode}: ${_extractErrorMessage(response)}',
        );
    }
  }

  static String _extractErrorMessage(Response response) {
    try {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return data['message'] as String;
        }
        if (data.containsKey('error')) {
          final error = data['error'];
          if (error is String) return error;
          if (error is Map && error.containsKey('message')) {
            return error['message'] as String;
          }
        }
      }

      return 'Erro desconhecido';
    } catch (e) {
      return 'Erro ao processar resposta';
    }
  }

  static String getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else {
      return 'Erro desconhecido';
    }
  }

  static bool isNetworkError(Failure failure) {
    return failure is NetworkFailure;
  }

  static bool isAuthError(Failure failure) {
    return failure is AuthenticationFailure;
  }
}
