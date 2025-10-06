import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:projeto_do_leitinho/core/utils/validators.dart';
import 'package:projeto_do_leitinho/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthCollectorAuthenticated] when CPF is valid',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          LoginRequested(document: '123.456.789-09', password: '123456'),
        ),
        wait: const Duration(seconds: 2),
        expect: () => [AuthLoading(), AuthCollectorAuthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthProducerAuthenticated] when CNPJ is valid',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          LoginRequested(document: '12.345.678/0001-90', password: '123456'),
        ),
        wait: const Duration(seconds: 2),
        expect: () => [AuthLoading(), AuthProducerAuthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when CPF is invalid',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          LoginRequested(document: '111.111.111-11', password: '123456'),
        ),
        wait: const Duration(seconds: 2),
        expect: () => [
          AuthLoading(),
          isA<AuthError>().having(
            (state) => state.message,
            'message',
            'CPF inválido',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when document is invalid length',
        build: () => authBloc,
        act: (bloc) =>
            bloc.add(LoginRequested(document: '12345', password: '123456')),
        wait: const Duration(seconds: 2),
        expect: () => [
          AuthLoading(),
          isA<AuthError>().having(
            (state) => state.message,
            'message',
            'Documento inválido',
          ),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthInitial] when logout is requested',
        build: () => authBloc,
        seed: () => AuthCollectorAuthenticated(),
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [AuthInitial()],
      );
    });
  });

  group('Validators', () {
    test('validates CPF correctly', () {
      expect(Validators.isCPF('123.456.789-09'), isTrue);
      expect(Validators.isCPF('111.111.111-11'), isFalse);
      expect(Validators.isCPF('12345678909'), isFalse);
    });

    test('validates CNPJ correctly', () {
      expect(Validators.isCNPJ('12.345.678/0001-90'), isTrue);
      expect(Validators.isCNPJ('11.111.111/1111-11'), isFalse);
    });

    test('validateDocument returns correct error messages', () {
      expect(Validators.validateDocument(null), 'Campo obrigatório');
      expect(Validators.validateDocument(''), 'Campo obrigatório');
      expect(Validators.validateDocument('12345'), 'CPF ou CNPJ inválido');
    });

    test('validatePassword returns correct error messages', () {
      expect(Validators.validatePassword(null), 'Campo obrigatório');
      expect(Validators.validatePassword(''), 'Campo obrigatório');
      expect(
        Validators.validatePassword('123'),
        'Senha deve ter no mínimo 6 caracteres',
      );
      expect(Validators.validatePassword('123456'), isNull);
    });
  });
}
