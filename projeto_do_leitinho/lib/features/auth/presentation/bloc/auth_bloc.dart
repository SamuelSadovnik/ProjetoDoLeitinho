import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String document;
  final String password;
  final ApiService apiService;

  LoginRequested({
    required this.document,
    required this.password,
    required this.apiService,
  });

  @override
  List<Object?> get props => [document, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {
  final ApiService apiService;

  CheckAuthStatus({required this.apiService});
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCollectorAuthenticated extends AuthState {
  final UserModel user;

  AuthCollectorAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthProducerAuthenticated extends AuthState {
  final UserModel user;

  AuthProducerAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthDairyAuthenticated extends AuthState {
  final UserModel user;

  AuthDairyAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthAdminAuthenticated extends AuthState {
  final UserModel user;

  AuthAdminAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Limpa o documento removendo pontos, traços e barras
      final cleanDocument = event.document.replaceAll(RegExp(r'[^\d]'), '');

      // Busca todos os usuários
      final response = await event.apiService.getAllUsers();

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;

        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> usersJson = data['content'];

          // Procura o usuário pelo documento
          UserModel? foundUser;
          for (var userJson in usersJson) {
            final user = UserModel.fromJson(userJson);
            final userCleanDocument = user.document.replaceAll(
              RegExp(r'[^\d]'),
              '',
            );

            if (userCleanDocument == cleanDocument) {
              // Verifica a senha (em produção, isso seria feito no backend)
              if (user.passwordHash == event.password) {
                foundUser = user;
                break;
              } else {
                emit(AuthError(message: 'Senha incorreta'));
                return;
              }
            }
          }

          if (foundUser == null) {
            emit(AuthError(message: 'Usuário não encontrado'));
            return;
          }

          if (!foundUser.active) {
            emit(
              AuthError(
                message:
                    'Usuário inativo. Entre em contato com o administrador.',
              ),
            );
            return;
          }

          // Define o usuário atual no serviço
          event.apiService.setCurrentUser(foundUser);

          // Verifica o tipo de usuário e emite o estado apropriado
          if (foundUser.isCollector) {
            emit(AuthCollectorAuthenticated(user: foundUser));
          } else if (foundUser.isProducer) {
            emit(AuthProducerAuthenticated(user: foundUser));
          } else if (foundUser.isDairy) {
            emit(AuthDairyAuthenticated(user: foundUser));
          } else if (foundUser.isAdmin) {
            emit(AuthAdminAuthenticated(user: foundUser));
          } else {
            emit(AuthError(message: 'Tipo de usuário não suportado'));
          }
        } else {
          emit(
            AuthError(message: data['message'] ?? 'Erro ao buscar usuários'),
          );
        }
      } else {
        emit(AuthError(message: 'Erro ao conectar com o servidor'));
      }
    } catch (e) {
      print('Erro no login: $e');
      emit(AuthError(message: 'Erro ao fazer login: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.apiService.currentUser;
    if (user != null) {
      if (user.isCollector) {
        emit(AuthCollectorAuthenticated(user: user));
      } else if (user.isProducer) {
        emit(AuthProducerAuthenticated(user: user));
      }
    } else {
      emit(AuthInitial());
    }
  }
}
