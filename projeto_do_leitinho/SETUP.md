# Setup Guide - PuroLácteo

## Requisitos

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Dispositivo Android ou Emulador

## Instalação

### 1. Clone o repositório

```bash
git clone <repository-url>
cd projeto_do_leitinho
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Verifique a instalação

```bash
flutter doctor
```

## Executar o App

### Debug Mode

```bash
# Android
flutter run

# Específico para um dispositivo
flutter run -d <device-id>

# Ver dispositivos disponíveis
flutter devices
```

### Release Mode

```bash
flutter run --release
```

## Build

### Android APK

```bash
# APK Debug
flutter build apk --debug

# APK Release
flutter build apk --release

# APK Split per ABI (menor tamanho)
flutter build apk --split-per-abi
```

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

## Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/      # Cores, strings
│   ├── theme/          # Tema do app
│   ├── utils/          # Validadores, formatadores
│   └── widgets/        # Widgets reutilizáveis
├── features/
│   ├── auth/           # Autenticação
│   ├── collector/      # Funcionalidades do coletor
│   └── producer/       # Funcionalidades do produtor
└── main.dart
```

## Flavors (Ambientes)

### Desenvolvimento

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Produção

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

## Testes

### Executar todos os testes

```bash
flutter test
```

### Executar teste específico

```bash
flutter test test/auth_bloc_test.dart
```

### Cobertura de código

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Comandos Úteis

### Limpar build

```bash
flutter clean
flutter pub get
```

### Análise de código

```bash
flutter analyze
```

### Formatar código

```bash
dart format .
```

### Verificar dependências outdated

```bash
flutter pub outdated
```

### Upgrade dependências

```bash
flutter pub upgrade
```

## Debugging

### Hot Reload

Durante execução, pressione `r` no terminal

### Hot Restart

Durante execução, pressione `R` no terminal

### DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Credenciais de Teste

**Coletor:**

- CPF: `123.456.789-09` (qualquer CPF válido)
- Senha: `123456`

**Produtor:**

- CNPJ: `12.345.678/0001-90` (qualquer CNPJ válido)
- Senha: `123456`

## Troubleshooting

### Problema: Gradle build failed

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problema: Package not found

```bash
flutter pub cache repair
flutter pub get
```

### Problema: iOS build failed

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## Próximos Passos

1. Configurar backend API
2. Implementar persistência local (Hive/Isar)
3. Configurar sincronização offline
4. Implementar geração de PDF
5. Configurar CI/CD
6. Adicionar testes unitários e de widget
7. Configurar Analytics e Crashlytics
