import "package:shike_guanjia/models/models.dart";

/// Authentication service interface
abstract class AuthService {
  /// Send verification code to phone number
  Future<bool> sendVerificationCode(String phone);

  /// Login with phone and verification code
  Future<User?> login(String phone, String code);

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
