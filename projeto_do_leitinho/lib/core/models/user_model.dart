class UserType {
  final int iduserTypes;
  final String name;

  UserType({required this.iduserTypes, required this.name});

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      iduserTypes: json['iduserTypes'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'iduserTypes': iduserTypes, 'name': name};
  }

  bool get isProducer => iduserTypes == 2;
  bool get isCollector => iduserTypes == 1;
  bool get isAdmin => iduserTypes == 4;
  bool get isDairy => iduserTypes == 3;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserType &&
          runtimeType == other.runtimeType &&
          iduserTypes == other.iduserTypes;

  @override
  int get hashCode => iduserTypes.hashCode;
}

class UserModel {
  final int iduser;
  final String name;
  final String document;
  final String email;
  final String? passwordHash;
  final UserType user;
  final bool active;

  UserModel({
    required this.iduser,
    required this.name,
    required this.document,
    required this.email,
    this.passwordHash,
    required this.user,
    required this.active,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      iduser: json['iduser'] ?? 0,
      name: json['name'] ?? '',
      document: json['document'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'],
      user: UserType.fromJson(json['user'] ?? {}),
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iduser': iduser,
      'name': name,
      'document': document,
      'email': email,
      'passwordHash': passwordHash,
      'user': user.toJson(),
      'active': active,
    };
  }

  bool get isProducer => user.isProducer;
  bool get isCollector => user.isCollector;
  bool get isDairy => user.isDairy;
  bool get isAdmin => user.isAdmin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          iduser == other.iduser;

  @override
  int get hashCode => iduser.hashCode;
}
