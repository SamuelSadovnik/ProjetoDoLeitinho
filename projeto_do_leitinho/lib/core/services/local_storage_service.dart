import 'package:hive_flutter/hive_flutter.dart';
import '../../features/collector/domain/models/collection_model.dart';

class LocalStorageService {
  static const String _userBox = 'user_box';
  static const String _collectionBox = 'collection_box';
  static const String _settingsBox = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    // Hive.registerAdapter(CollectionModelAdapter());

    // Open boxes
    await Hive.openBox(_userBox);
    await Hive.openBox(_collectionBox);
    await Hive.openBox(_settingsBox);
  }

  // User data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final box = Hive.box(_userBox);
    await box.put('current_user', user);
  }

  static Map<String, dynamic>? getUser() {
    final box = Hive.box(_userBox);
    final user = box.get('current_user');
    if (user is Map<String, dynamic>) {
      return user;
    }
    return null;
  }

  static Future<void> clearUser() async {
    final box = Hive.box(_userBox);
    await box.delete('current_user');
  }

  // Auth token
  static Future<void> saveToken(String token) async {
    final box = Hive.box(_userBox);
    await box.put('auth_token', token);
  }

  static String? getToken() {
    final box = Hive.box(_userBox);
    return box.get('auth_token') as String?;
  }

  static Future<void> clearToken() async {
    final box = Hive.box(_userBox);
    await box.delete('auth_token');
  }

  // Pending collections (for offline sync)
  static Future<void> savePendingCollection(CollectionModel collection) async {
    final box = Hive.box(_collectionBox);
    final key = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    await box.put(key, collection.toJson());
  }

  static List<CollectionModel> getPendingCollections() {
    final box = Hive.box(_collectionBox);
    final collections = <CollectionModel>[];

    for (var key in box.keys) {
      if (key.toString().startsWith('pending_')) {
        final data = box.get(key);
        if (data != null) {
          collections.add(
            CollectionModel.fromJson(Map<String, dynamic>.from(data)),
          );
        }
      }
    }

    return collections;
  }

  static Future<void> removePendingCollection(String key) async {
    final box = Hive.box(_collectionBox);
    await box.delete(key);
  }

  static Future<void> clearPendingCollections() async {
    final box = Hive.box(_collectionBox);
    final keysToDelete = box.keys
        .where((key) => key.toString().startsWith('pending_'))
        .toList();

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  // Cached collections
  static Future<void> cacheCollections(
    List<CollectionModel> collections,
  ) async {
    final box = Hive.box(_collectionBox);
    final collectionsList = collections.map((c) => c.toJson()).toList();
    await box.put('cached_collections', collectionsList);
  }

  static List<CollectionModel> getCachedCollections() {
    final box = Hive.box(_collectionBox);
    final cached = box.get('cached_collections');

    if (cached is List) {
      return cached
          .map(
            (item) => CollectionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    return [];
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    final box = Hive.box(_settingsBox);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> clearAll() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_collectionBox).clear();
    await Hive.box(_settingsBox).clear();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
