import "package:shike_guanjia/models/models.dart";

class MockDataStore {
  final users = <String, User>{};
  final families = <String, Family>{};
  final children = <String, Child>{};
  final classes = <String, TrainingClass>{};
  final lessons = <String, Lesson>{};
  final attendances = <String, Attendance>{};
  final leaves = <String, LeaveRecord>{};
  final syncQueue = <SyncQueueItem>[];

  User? currentUser;
  Family? currentFamily;
  bool online = true;
  SyncStatus syncStatus = SyncStatus.synced;
  DateTime? lastSyncAt;

  void reset() {
    users.clear();
    families.clear();
    children.clear();
    classes.clear();
    lessons.clear();
    attendances.clear();
    leaves.clear();
    syncQueue.clear();
    clearSession();
    online = true;
    syncStatus = SyncStatus.synced;
    lastSyncAt = null;
  }

  void seedTestData() {
    // 测试用户：13800138000，验证码123456
    final testUser = User(
      id: "user_123",
      phone: "13800138000",
      createdAt: DateTime(2026, 6, 1),
    );
    users[testUser.id] = testUser;

    // 测试家庭
    final testFamily = Family(
      id: "family_123",
      name: "测试家庭",
      members: [
        FamilyMember(
          id: "member_1",
          userId: testUser.id,
          relation: FamilyRelation.mother,
          displayName: "妈妈",
          createdAt: DateTime(2026, 6, 1),
        )
      ],
    );
    families[testFamily.id] = testFamily;
    currentUser = testUser;
    currentFamily = testFamily;

    // 测试孩子
    final testChild = Child(
      id: "child_123",
      name: "小明",
      age: 8,
      familyId: testFamily.id,
      createdAt: DateTime(2026, 6, 1),
    );
    children[testChild.id] = testChild;
  }

  // 查找工具方法
  List<Child> getChildrenByFamily(String familyId) {
    return children.values.where((c) => c.familyId == familyId).toList();
  }

  List<TrainingClass> getClassesByFamily(String familyId, {String? childId, ClassStatus? status}) {
    return classes.values.where((c) {
      if (c.familyId != familyId) return false;
      if (childId != null && c.childId != childId) return false;
      if (status != null && c.status != status) return false;
      return true;
    }).toList();
  }

  List<Lesson> getLessonsByClass(String classId) {
    return lessons.values.where((l) => l.classId == classId).toList();
  }

  List<Lesson> getLessonsByFamily(String familyId, {String? childId, DateTime? start, DateTime? end}) {
    return lessons.values.where((l) {
      final cls = classes[l.classId];
      if (cls == null || cls.familyId != familyId) return false;
      if (childId != null && cls.childId != childId) return false;
      if (start != null && l.scheduledDate.isBefore(start)) return false;
      if (end != null && l.scheduledDate.isAfter(end)) return false;
      return true;
    }).toList();
  }

  TrainingClass? getClassForLesson(String lessonId) {
    final lesson = lessons[lessonId];
    return lesson != null ? classes[lesson.classId] : null;
  }

  Child? getChildForClass(String classId) {
    final cls = classes[classId];
    return cls != null ? children[cls.childId] : null;
  }

  void clearSession() {
    currentUser = null;
    currentFamily = null;
  }
}
