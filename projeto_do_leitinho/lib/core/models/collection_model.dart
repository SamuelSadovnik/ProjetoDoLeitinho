import 'user_model.dart';
import 'farm_model.dart';

class AnimalModel {
  final int idanimal;
  final String name;

  AnimalModel({required this.idanimal, required this.name});

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      idanimal: json['idanimal'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idanimal': idanimal, 'name': name};
  }

  /// Retorna o nome formatado com primeira letra maiúscula
  String get displayName =>
      name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalModel &&
          runtimeType == other.runtimeType &&
          idanimal == other.idanimal;

  @override
  int get hashCode => idanimal.hashCode;
}

class CollectionModel {
  final int idcollection;
  final AnimalModel animal;
  final FarmModel farm;
  final UserModel producer;
  final UserModel collector;
  final double quantity;
  final double temperature;
  final double acidity;
  final bool producerPresent;
  final String observations;
  final DateTime collectionDate;
  final bool edited;
  final int editCount;

  CollectionModel({
    required this.idcollection,
    required this.animal,
    required this.farm,
    required this.producer,
    required this.collector,
    required this.quantity,
    required this.temperature,
    required this.acidity,
    required this.producerPresent,
    required this.observations,
    required this.collectionDate,
    this.edited = false,
    this.editCount = 0,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      idcollection: json['idcollection'] ?? 0,
      animal: AnimalModel.fromJson(json['animal'] ?? {}),
      farm: FarmModel.fromJson(json['farm'] ?? {}),
      producer: UserModel.fromJson(json['producer'] ?? {}),
      collector: UserModel.fromJson(json['collector'] ?? {}),
      quantity: (json['quantity'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      acidity: (json['acidity'] ?? 0).toDouble(),
      producerPresent: json['producerPresent'] ?? false,
      observations: json['observations'] ?? '',
      collectionDate: _parseDate(json['collectionDate']),
      edited: json['edited'] ?? false,
      editCount: json['editCount'] ?? 0,
    );
  }

  /// Parse de data que aceita múltiplos formatos
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is DateTime) return dateValue;

    final dateStr = dateValue.toString();

    // Formato dd/MM/yyyy HH:mm:ss
    if (dateStr.contains('/')) {
      try {
        final parts = dateStr.split(' ');
        final dateParts = parts[0].split('/');
        final timeParts = parts.length > 1
            ? parts[1].split(':')
            : ['0', '0', '0'];

        return DateTime(
          int.parse(dateParts[2]), // ano
          int.parse(dateParts[1]), // mês
          int.parse(dateParts[0]), // dia
          int.parse(timeParts[0]), // hora
          timeParts.length > 1 ? int.parse(timeParts[1]) : 0, // minuto
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0, // segundo
        );
      } catch (e) {
        return DateTime.now();
      }
    }

    // Formato ISO 8601 (yyyy-MM-ddTHH:mm:ss)
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idcollection': idcollection,
      'animal': animal.toJson(),
      'farm': farm.toJson(),
      'producer': producer.toJson(),
      'collector': collector.toJson(),
      'quantity': quantity,
      'temperature': temperature,
      'acidity': acidity,
      'producerPresent': producerPresent,
      'observations': observations,
      'collectionDate': collectionDate.toIso8601String(),
      'edited': edited,
      'editCount': editCount,
    };
  }

  String get formattedDate {
    return '${collectionDate.day.toString().padLeft(2, '0')}/${collectionDate.month.toString().padLeft(2, '0')}/${collectionDate.year} ${collectionDate.hour.toString().padLeft(2, '0')}:${collectionDate.minute.toString().padLeft(2, '0')}';
  }

  /// Indica se a coleta foi editada com indicador visual
  String get editedLabel =>
      edited ? ' (Editada${editCount > 1 ? ' ${editCount}x' : ''})' : '';
}
