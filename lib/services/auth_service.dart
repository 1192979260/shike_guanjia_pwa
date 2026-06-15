import "package:shike_guanjia/models/models.dart";

/// Authentication service interface
abstract class AuthService {
  /// Register with phone and password.
  Future<User?> register(String phone, String password);

  /// Login with phone and password.
  Future<User?> login(String phone, String password);

  /// Logout current user
  Future<void> logout();

  /// Get current user
  User? getCurrentUser();

  /// Check if user is logged in
  bool isLoggedIn();

  /// Add family member
  Future<FamilyMember?> addFamilyMember(String phone, FamilyRelation relation);

  /// Remove family member
  Future<bool> removeFamilyMember(String memberId);

  /// Get family members
  Future<List<FamilyMember>> getFamilyMembers();

  /// Get family
  Future<Family?> getFamily();
}
