class RepositoryResult<T> {
  const RepositoryResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  final bool isSuccess;
  final T? data;
  final Object? error;

  factory RepositoryResult.success(T data) {
    return RepositoryResult._(isSuccess: true, data: data);
  }

  factory RepositoryResult.failure(Object error) {
    return RepositoryResult._(isSuccess: false, error: error);
  }
}

abstract class BaseRepository {
  Future<RepositoryResult<T>> guard<T>(Future<T> Function() action) async {
    try {
      return RepositoryResult.success(await action());
    } catch (error) {
      return RepositoryResult.failure(error);
    }
  }

  Future<RepositoryResult<T>> guardNullable<T>(
    Future<T?> Function() action, {
    Object notFoundError = 'Record not found',
  }) async {
    try {
      final value = await action();
      if (value == null) {
        return RepositoryResult.failure(notFoundError);
      }
      return RepositoryResult.success(value);
    } catch (error) {
      return RepositoryResult.failure(error);
    }
  }
}
