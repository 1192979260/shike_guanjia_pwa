/// Child validation error
class ChildValidationError {
  final String field;
  final String message;

  ChildValidationError({required this.field, required this.message});
}

/// Child model with validation
class Child {
  final String id;
  final String name;
  final int? age;
  final String? avatarUrl;
  final String familyId;
  final DateTime createdAt;

  Child({
    required this.id,
    required this.name,
    this.age,
    this.avatarUrl,
    required this.familyId,
    required this.createdAt,
  });

  /// Validate child data
  static List<ChildValidationError> validate({
    required String name,
    int? age,
  }) {
    final errors = <ChildValidationError>[];

    // Name validation
    if (name.trim().isEmpty) {
      errors.add(ChildValidationError(
        field: 'name',
        message: '姓名不能为空',
      ));
    } else if (name.length > 50) {
      errors.add(ChildValidationError(
        field: 'name',
        message: '姓名不能超过50个字符',
      ));
    }

    // Age validation
    if (age != null) {
      if (age < 0) {
        errors.add(ChildValidationError(
          field: 'age',
          message: '年龄不能为负数',
        ));
      } else if (age > 18) {
        errors.add(ChildValidationError(
          field: 'age',
          message: '年龄不能超过18岁',
        ));
      }
    }

    return errors;
  }

  /// Validate this child instance
  List<ChildValidationError> validateSelf() {
    return validate(name: name, age: age);
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      avatarUrl: json['avatarUrl'] as String?,
      familyId: json['familyId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'avatarUrl': avatarUrl,
      'familyId': familyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Child copyWith({
    String? id,
    String? name,
    int? age,
    String? avatarUrl,
    String? familyId,
    DateTime? createdAt,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
