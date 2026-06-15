import 'package:shike_guanjia/data/repositories/base_repository.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/child_service.dart';


class ChildRepository extends BaseRepository {
  ChildRepository(this._service);

  final ChildService _service;

  Future<RepositoryResult<Child>> createChild({
    required String name,
    int? age,
    String? avatarUrl,
    required String familyId,
  }) {
    return guardNullable(
      () => _service.createChild(
        name: name,
        age: age,
        avatarUrl: avatarUrl,
        familyId: familyId,
      ),
      notFoundError: 'Invalid child data',
    );
  }

  Future<RepositoryResult<Child>> updateChild(
    String childId, {
    String? name,
    int? age,
    String? avatarUrl,
  }) {
    return guardNullable(
      () => _service.updateChild(
        childId,
        name: name,
        age: age,
        avatarUrl: avatarUrl,
      ),
      notFoundError: 'Child not found',
    );
  }

  Future<RepositoryResult<bool>> deleteChild(String childId) {
    return guard(() => _service.deleteChild(childId));
  }

  Future<RepositoryResult<Child>> getChild(String childId) {
    return guardNullable(
      () => _service.getChild(childId),
      notFoundError: 'Child not found',
    );
  }

  Future<RepositoryResult<List<Child>>> getChildren(String familyId) {
    return guard(() => _service.getChildren(familyId));
  }

  List<ChildValidationError> validateChild({
    required String name,
    int? age,
  }) {
    return _service.validateChild(name: name, age: age);
  }
}
