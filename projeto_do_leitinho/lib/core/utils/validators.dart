class Validators {
  static bool isCPF(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.length != 11) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(cleanValue)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanValue[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    digit1 = digit1 >= 10 ? 0 : digit1;

    if (int.parse(cleanValue[9]) != digit1) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanValue[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    digit2 = digit2 >= 10 ? 0 : digit2;

    return int.parse(cleanValue[10]) == digit2;
  }

  static bool isCNPJ(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.length != 14) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(cleanValue)) return false;

    int sum = 0;
    List<int> weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleanValue[i]) * weight1[i];
    }
    int digit1 = sum % 11 < 2 ? 0 : 11 - (sum % 11);

    if (int.parse(cleanValue[12]) != digit1) return false;

    sum = 0;
    List<int> weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cleanValue[i]) * weight2[i];
    }
    int digit2 = sum % 11 < 2 ? 0 : 11 - (sum % 11);

    return int.parse(cleanValue[13]) == digit2;
  }

  static String? validateDocument(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanValue.length == 11) {
      if (!isCPF(value)) return 'CPF inválido';
    } else if (cleanValue.length == 14) {
      if (!isCNPJ(value)) return 'CNPJ inválido';
    } else {
      return 'CPF ou CNPJ inválido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }
}
