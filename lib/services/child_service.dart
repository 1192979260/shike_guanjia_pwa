import "package:shike_guanjia/models/models.dart";

/// Child service interface
abstract class ChildService {
  /// Create child
  Future<Child?> createChild({
    required String name,
    int? age,
    String? avatarUrl,
    required String familyId,
  });

  /// Update child
  Future<Child?> updateChild(String childId, {
    String? name,
    int? age,
    String? avatarUrl,
  });

  /// Delete child
  Future<bool> deleteChild(String childId);

  /// Get child by ID
  Future<Child?> getChild(String childId);

  /// Get all children for family
  Future<List<Child>> getChildren(String familyId);

  /// Validate child data
  List<ChildValidationError> validateChild({
    required String name,
    int? age,
  });
}
