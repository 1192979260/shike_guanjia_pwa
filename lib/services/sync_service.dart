import "package:shike_guanjia/models/models.dart";

/// Sync service interface
abstract class SyncService {
  /// Initialize sync service
  Future<void> initialize();

  /// Sync all pending changes
  Future<SyncResult> syncAll();

  /// Sync specific entity
  Future<SyncResult> syncEntity(String entityType, String entityId);

  /// Get sync status
  Future<SyncStatus> getSyncStatus();

  /// Get pending changes count
  Future<int> getPendingChangesCount();

  /// Get sync queue
  Future<List<SyncQueueItem>> getSyncQueue();

  /// Add sync operation to queue
  Future<void> queueSyncOperation(SyncQueueItem item);

  /// Clear sync queue
  Future<void> clearSyncQueue();

  /// Retry failed sync operations
  Future<SyncResult> retryFailed();

  /// Set sync callback
  void setSyncCallback(Function(SyncStatus, String?) callback);

  /// Check if online
  bool isOnline();

  /// Set online status
  void setOnlineStatus(bool online);
}

/// Sync result
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.errorMessage,
  });
}
