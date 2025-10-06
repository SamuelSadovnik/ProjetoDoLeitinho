import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: AppConfig.instance.apiBaseUrl);

    final connectivityService = ConnectivityService();

    final syncService = SyncService(
      apiService: apiService,
      connectivityService: connectivityService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: connectivityService),
        RepositoryProvider.value(value: syncService),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(),
        child: MaterialApp(
          title: AppConfig.instance.appName,
          debugShowCheckedModeBanner: !AppConfig.instance.isProduction,
          theme: AppTheme.lightTheme,
          home: const LoginPage(),
          routes: {'/login': (context) => const LoginPage()},
        ),
      ),
    );
  }
}
