import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(Environment.development);

  await LocalStorageService.init();

  runApp(const MyApp());
}
