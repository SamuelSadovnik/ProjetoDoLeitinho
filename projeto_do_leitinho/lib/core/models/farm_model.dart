import 'user_model.dart';

class FarmModel {
  final int idfarm;
  final String name;
  final UserModel producer;
  final bool active;

  FarmModel({
    required this.idfarm,
    required this.name,
    required this.producer,
    required this.active,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      idfarm: json['idfarm'] ?? 0,
      name: json['name'] ?? '',
      producer: UserModel.fromJson(json['producer'] ?? {}),
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idfarm': idfarm,
      'name': name,
      'producer': producer.toJson(),
      'active': active,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmModel &&
          runtimeType == other.runtimeType &&
          idfarm == other.idfarm;

  @override
  int get hashCode => idfarm.hashCode;
}
