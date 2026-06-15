/// Sync status for entities
enum SyncStatus {
  synced,      // 已同步
  pending,     // 待同步
  conflict,    // 冲突
}

/// Base persistence model with sync tracking
mixin Persistable {
  String get id;
  DateTime get createdAt;
  DateTime? get updatedAt;
  SyncStatus get syncStatus;
  String? get localId; // Temporary local ID before sync
}

/// User persistence model
class UserPersist {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;
  final String? localId;

  UserPersist({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatarUrl,
    this.syncStatus = SyncStatus.synced,
    this.localId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserPersist.fromJson(Map<String, dynamic> json) {
    return UserPersist(
      id: json['id'] as String,
      phone: json['phone'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
      localId: json['localId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'syncStatus': syncStatus.name,
      'localId': localId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'syncStatus': syncStatus.index,
      'localId': localId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Sync queue operation
enum SyncOperation {
  create,
  update,
  delete,
}

/// Sync queue item
class SyncQueueItem {
  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? nextRetryAt;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    this.retryCount = 0,
    this.nextRetryAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == json['operation'],
        orElse: () => SyncOperation.create,
      ),
      data: json['data'] as Map<String, dynamic>,
      retryCount: json['retryCount'] as int? ?? 0,
      nextRetryAt: json['nextRetryAt'] != null
          ? DateTime.parse(json['nextRetryAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation.name,
      'data': data,
      'retryCount': retryCount,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
