import "package:shike_guanjia/models/models.dart";
import 'package:shike_guanjia/services/mock/mock_data_store.dart';
import 'package:shike_guanjia/services/sync_service.dart';

class MockSyncService implements SyncService {
  MockSyncService(this._store);

  final MockDataStore _store;
  void Function(SyncStatus, String?)? _callback;

  @override
  Future<void> initialize() async {
    _store.syncStatus = _store.syncQueue.isEmpty
        ? SyncStatus.synced
        : SyncStatus.pending;
  }

  @override
  Future<SyncResult> syncAll() async {
    if (!_store.online) {
      _setStatus(SyncStatus.pending, 'Device is offline');
      return SyncResult(
        success: false,
        failedCount: _store.syncQueue.length,
        errorMessage: 'Device is offline',
      );
    }

    final count = _store.syncQueue.length;
    _store.syncQueue.clear();
    _store.lastSyncAt = DateTime.now();
    _setStatus(SyncStatus.synced, null);
    return SyncResult(success: true, syncedCount: count);
  }

  @override
  Future<SyncResult> syncEntity(String entityType, String entityId) async {
    if (!_store.online) {
      _setStatus(SyncStatus.pending, 'Device is offline');
      return _SyncResultOffline();
    }

    final before = _store.syncQueue.length;
    _store.syncQueue.removeWhere(
      (item) => item.entityType == entityType && item.entityId == entityId,
    );
    final synced = before - _store.syncQueue.length;
    _setStatus(_store.syncQueue.isEmpty ? SyncStatus.synced : SyncStatus.pending, null);
    return SyncResult(success: true, syncedCount: synced);
  }

  @override
  Future<SyncStatus> getSyncStatus() async => _store.syncStatus;

  @override
  Future<int> getPendingChangesCount() async => _store.syncQueue.length;

  @override
  Future<List<SyncQueueItem>> getSyncQueue() async {
    return List.unmodifiable(_store.syncQueue);
  }

  @override
  Future<void> queueSyncOperation(SyncQueueItem item) async {
    _store.syncQueue.add(item);
    _setStatus(SyncStatus.pending, null);
  }

  @override
  Future<void> clearSyncQueue() async {
    _store.syncQueue.clear();
    _setStatus(SyncStatus.synced, null);
  }

  @override
  Future<SyncResult> retryFailed() => syncAll();

  @override
  void setSyncCallback(Function(SyncStatus, String?) callback) {
    _callback = callback;
  }

  @override
  bool isOnline() => _store.online;

  @override
  void setOnlineStatus(bool online) {
    _store.online = online;
    _setStatus(
      online && _store.syncQueue.isEmpty ? SyncStatus.synced : SyncStatus.pending,
      online ? null : 'Device is offline',
    );
  }

  void _setStatus(SyncStatus status, String? message) {
    _store.syncStatus = status;
    _callback?.call(status, message);
  }
}

class _SyncResultOffline extends SyncResult {
  _SyncResultOffline()
      : super(
          success: false,
          failedCount: 1,
          errorMessage: 'Device is offline',
        );
}
