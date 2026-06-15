import 'package:shike_guanjia/data/repositories/base_repository.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/auth_service.dart';

class UserRepository extends BaseRepository {
  UserRepository(this._service);

  final AuthService _service;

  Future<RepositoryResult<User>> login(String phone, String password) {
    return guardNullable(
      () => _service.login(phone, password),
      notFoundError: 'Invalid phone or password',
    );
  }

  Future<RepositoryResult<User>> register(String phone, String password) {
    return guardNullable(
      () => _service.register(phone, password),
      notFoundError: 'Registration failed',
    );
  }

  Future<RepositoryResult<void>> logout() {
    return guard(_service.logout);
  }

  User? getCurrentUser() => _service.getCurrentUser();

  bool isLoggedIn() => _service.isLoggedIn();

  Future<RepositoryResult<FamilyMember>> addFamilyMember(
    String phone,
    FamilyRelation relation,
  ) {
    return guardNullable(
      () => _service.addFamilyMember(phone, relation),
      notFoundError: 'Family member cannot be added',
    );
  }

  Future<RepositoryResult<bool>> removeFamilyMember(String memberId) {
    return guard(() => _service.removeFamilyMember(memberId));
  }

  Future<RepositoryResult<List<FamilyMember>>> getFamilyMembers() {
    return guard(_service.getFamilyMembers);
  }

  Future<RepositoryResult<Family>> getFamily() {
    return guardNullable(_service.getFamily, notFoundError: 'Family not found');
  }
}
