import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize config for staging
  AppConfig.initialize(Environment.staging);

  // Initialize local storage
  await LocalStorageService.init();

  runApp(const MyApp());
}
