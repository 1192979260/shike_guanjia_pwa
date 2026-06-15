/// User model
class User {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? phone,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Family member relation type
enum FamilyRelation {
  mother, // 宝妈
  father, // 爸爸
}

/// Family member
class FamilyMember {
  final String id;
  final String userId;
  final FamilyRelation relation;
  final String? displayName;
  final DateTime createdAt;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.relation,
    this.displayName,
    required this.createdAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      relation: FamilyRelation.values.firstWhere(
        (e) => e.name == json['relation'],
        orElse: () => FamilyRelation.mother,
      ),
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'relation': relation.name,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Family
class Family {
  final String id;
  final String name;
  final List<FamilyMember> members;

  Family({
    required this.id,
    required this.name,
    required this.members,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List?;
    final members = membersJson
        ?.map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
        .toList() ?? [];

    return Family(
      id: json['id'] as String,
      name: json['name'] as String,
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members.map((m) => m.toJson()).toList(),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    List<FamilyMember>? members,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }
}
