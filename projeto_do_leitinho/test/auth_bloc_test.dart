import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_do_leitinho/core/utils/validators.dart';

void main() {
  // Os testes do AuthBloc precisam ser atualizados para usar mocks do ApiService
  // Por enquanto, mantemos apenas os testes de validação

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
