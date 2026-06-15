import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'shike_guanjia.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _databaseName);
    return _database = await openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );
  }

  Future<void> close() async {
    final existing = _database;
    if (existing != null) {
      await existing.close();
      _database = null;
    }
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL UNIQUE,
        nickname TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE families (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE family_members (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        relation TEXT NOT NULL,
        display_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE children (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        name TEXT NOT NULL,
        age INTEGER,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE training_classes (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        family_id TEXT NOT NULL,
        institution_name TEXT NOT NULL,
        class_name TEXT NOT NULL,
        course_name TEXT NOT NULL,
        teacher_name TEXT,
        teacher_phone TEXT,
        total_hours INTEGER NOT NULL,
        used_hours INTEGER NOT NULL DEFAULT 0,
        remaining_hours INTEGER NOT NULL,
        total_fee REAL NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        recurring_rule_json TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        class_id TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        status TEXT NOT NULL,
        actual_date TEXT,
        checkin_time TEXT,
        is_makeup INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        leave_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (class_id) REFERENCES training_classes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendances (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        child_id TEXT NOT NULL,
        checkin_time TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE,
        FOREIGN KEY (class_id) REFERENCES training_classes (id) ON DELETE CASCADE,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE leave_records (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        child_id TEXT NOT NULL,
        request_time TEXT NOT NULL,
        status TEXT NOT NULL,
        reason TEXT,
        makeup_lesson_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0,
        local_id TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE,
        FOREIGN KEY (class_id) REFERENCES training_classes (id) ON DELETE CASCADE,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        next_retry_at TEXT
      )
    ''');

    await _createIndexes(db);
  }

  Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await _createSchema(db, newVersion);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_children_family ON children (family_id)');
    await db.execute('CREATE INDEX idx_classes_family ON training_classes (family_id)');
    await db.execute('CREATE INDEX idx_classes_child ON training_classes (child_id)');
    await db.execute('CREATE INDEX idx_lessons_class_date ON lessons (class_id, scheduled_date)');
    await db.execute('CREATE INDEX idx_attendance_child_time ON attendances (child_id, checkin_time)');
    await db.execute('CREATE INDEX idx_leave_child_time ON leave_records (child_id, request_time)');
    await db.execute('CREATE INDEX idx_sync_queue_entity ON sync_queue (entity_type, entity_id)');
    await db.execute('CREATE INDEX idx_sync_queue_retry ON sync_queue (next_retry_at)');
  }
}
