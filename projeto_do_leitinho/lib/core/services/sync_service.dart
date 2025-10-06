import 'dart:async';
import 'api_service.dart';
import 'local_storage_service.dart';
import 'connectivity_service.dart';
import '../../features/collector/domain/models/collection_model.dart';

class SyncService {
  final ApiService apiService;
  final ConnectivityService connectivityService;

  bool _isSyncing = false;
  final _syncController = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStream => _syncController.stream;

  SyncService({required this.apiService, required this.connectivityService}) {
    _initSync();
  }

  void _initSync() {
    connectivityService.connectionStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        syncPendingCollections();
      }
    });
  }

  Future<void> syncPendingCollections() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final pendingCollections = LocalStorageService.getPendingCollections();

      if (pendingCollections.isEmpty) {
        _syncController.add(SyncStatus.completed);
        _isSyncing = false;
        return;
      }

      int successCount = 0;
      int failCount = 0;

      for (var collection in pendingCollections) {
        try {
          await apiService.createCollection(collection.toJson());

          // Remove from pending after successful sync
          final key =
              'pending_${collection.collectionDate.millisecondsSinceEpoch}';
          await LocalStorageService.removePendingCollection(key);

          successCount++;
        } catch (e) {
          print('Failed to sync collection: $e');
          failCount++;
        }
      }

      if (failCount == 0) {
        _syncController.add(SyncStatus.completed);
      } else {
        _syncController.add(SyncStatus.partiallyCompleted);
      }

      print('Sync completed: $successCount success, $failCount failed');
    } catch (e) {
      print('Sync error: $e');
      _syncController.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> saveCollectionOffline(CollectionModel collection) async {
    await LocalStorageService.savePendingCollection(collection);

    // Try to sync immediately if online
    if (connectivityService.isConnected) {
      await syncPendingCollections();
    }
  }

  int getPendingCount() {
    return LocalStorageService.getPendingCollections().length;
  }

  void dispose() {
    _syncController.close();
  }
}

enum SyncStatus { idle, syncing, completed, partiallyCompleted, failed }
