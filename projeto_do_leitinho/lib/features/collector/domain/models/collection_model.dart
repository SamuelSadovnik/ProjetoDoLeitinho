import 'package:equatable/equatable.dart';

class CollectionModel extends Equatable {
  final int? id;
  final String farmId;
  final String farmName;
  final String producerId;
  final String producerName;
  final double quantity;
  final double temperature;
  final double acidity;
  final bool producerPresent;
  final String? observations;
  final DateTime collectionDate;
  final bool synced;
  final String? collectorId;

  const CollectionModel({
    this.id,
    required this.farmId,
    required this.farmName,
    required this.producerId,
    required this.producerName,
    required this.quantity,
    required this.temperature,
    required this.acidity,
    required this.producerPresent,
    this.observations,
    required this.collectionDate,
    this.synced = false,
    this.collectorId,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as int?,
      farmId: json['farmId'] as String,
      farmName: json['farmName'] as String,
      producerId: json['producerId'] as String,
      producerName: json['producerName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      acidity: (json['acidity'] as num).toDouble(),
      producerPresent: json['producerPresent'] as bool,
      observations: json['observations'] as String?,
      collectionDate: DateTime.parse(json['collectionDate'] as String),
      synced: json['synced'] as bool? ?? false,
      collectorId: json['collectorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'farmName': farmName,
      'producerId': producerId,
      'producerName': producerName,
      'quantity': quantity,
      'temperature': temperature,
      'acidity': acidity,
      'producerPresent': producerPresent,
      'observations': observations,
      'collectionDate': collectionDate.toIso8601String(),
      'synced': synced,
      'collectorId': collectorId,
    };
  }

  CollectionModel copyWith({
    int? id,
    String? farmId,
    String? farmName,
    String? producerId,
    String? producerName,
    double? quantity,
    double? temperature,
    double? acidity,
    bool? producerPresent,
    String? observations,
    DateTime? collectionDate,
    bool? synced,
    String? collectorId,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      producerId: producerId ?? this.producerId,
      producerName: producerName ?? this.producerName,
      quantity: quantity ?? this.quantity,
      temperature: temperature ?? this.temperature,
      acidity: acidity ?? this.acidity,
      producerPresent: producerPresent ?? this.producerPresent,
      observations: observations ?? this.observations,
      collectionDate: collectionDate ?? this.collectionDate,
      synced: synced ?? this.synced,
      collectorId: collectorId ?? this.collectorId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    farmId,
    farmName,
    producerId,
    producerName,
    quantity,
    temperature,
    acidity,
    producerPresent,
    observations,
    collectionDate,
    synced,
    collectorId,
  ];
}
