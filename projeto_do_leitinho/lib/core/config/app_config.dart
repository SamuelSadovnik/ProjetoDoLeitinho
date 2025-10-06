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

  static void initialize(Environment env) {
    switch (env) {
      case Environment.development:
        instance = AppConfig._(
          environment: env,
          apiBaseUrl: 'http://localhost:3000/api',
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
