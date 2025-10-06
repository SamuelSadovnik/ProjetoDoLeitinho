import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/validators.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String document;
  final String password;

  LoginRequested({required this.document, required this.password});

  @override
  List<Object?> get props => [document, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCollectorAuthenticated extends AuthState {}

class AuthProducerAuthenticated extends AuthState {}

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
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simula API call

      final cleanDocument = event.document.replaceAll(RegExp(r'[^\d]'), '');

      // CPF = 11 dígitos -> Coletor
      // CNPJ = 14 dígitos -> Produtor
      if (cleanDocument.length == 11) {
        if (!Validators.isCPF(event.document)) {
          emit(AuthError(message: 'CPF inválido'));
          return;
        }
        emit(AuthCollectorAuthenticated());
      } else if (cleanDocument.length == 14) {
        if (!Validators.isCNPJ(event.document)) {
          emit(AuthError(message: 'CNPJ inválido'));
          return;
        }
        emit(AuthProducerAuthenticated());
      } else {
        emit(AuthError(message: 'Documento inválido'));
      }
    } catch (e) {
      emit(AuthError(message: 'Erro ao fazer login: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }
}
