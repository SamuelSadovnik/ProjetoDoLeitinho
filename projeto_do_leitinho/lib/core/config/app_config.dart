import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool enableAnalytics;
  final int apiTimeout;

  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.apiTimeout,
  });

  static late AppConfig instance;

  // ⚠️ ALTERE ESTE IP PARA O IP DA SUA MÁQUINA NA REDE LOCAL (para dispositivos físicos)
  // Para descobrir seu IP, execute 'ipconfig' no terminal Windows
  static const String _localMachineIp = '192.168.229.184';

  static String _getDevApiUrl() {
    if (kIsWeb) {
      // Para Chrome/Web, usa localhost
      return 'http://localhost:8080/api';
    } else {
      // Para dispositivo físico Android/iOS, usa o IP da máquina
      return 'http://$_localMachineIp:8080/api';
    }
  }

  static void initialize(Environment env) {
    switch (env) {
      case Environment.development:
        instance = AppConfig._(
          environment: env,
          apiBaseUrl: _getDevApiUrl(),
          appName: 'PuroLácteo DEV',
          enableLogging: true,
          enableAnalytics: false,
          apiTimeout: 30,
        );
        break;

      case Environment.staging:
        instance = AppConfig._(
          environment: env,
          apiBaseUrl: 'https://staging-api.purolacteo.com/api',
          appName: 'PuroLácteo STAGING',
          enableLogging: true,
          enableAnalytics: true,
          apiTimeout: 30,
        );
        break;

      case Environment.production:
        instance = AppConfig._(
          environment: env,
          apiBaseUrl: 'https://api.purolacteo.com/api',
          appName: 'PuroLácteo',
          enableLogging: false,
          enableAnalytics: true,
          apiTimeout: 30,
        );
        break;
    }
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
