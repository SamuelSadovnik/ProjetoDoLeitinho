import 'package:equatable/equatable.dart';

class QualityIndicators extends Equatable {
  final String antibiotic;
  final String fat;
  final Map<String, String>? others;

  const QualityIndicators({
    required this.antibiotic,
    required this.fat,
    this.others,
  });

  factory QualityIndicators.fromJson(Map<String, dynamic> json) {
    return QualityIndicators(
      antibiotic: json['antibiotic'] as String,
      fat: json['fat'] as String,
      others: json['others'] != null
          ? Map<String, String>.from(json['others'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'antibiotic': antibiotic, 'fat': fat, 'others': others};
  }

  @override
  List<Object?> get props => [antibiotic, fat, others];
}

class ProducerCollectionModel extends Equatable {
  final int id;
  final DateTime date;
  final double quantity;
  final double temperature;
  final double acidity;
  final String quality;
  final bool approved;
  final QualityIndicators? indicators;
  final String? collectorName;
  final String? observations;

  const ProducerCollectionModel({
    required this.id,
    required this.date,
    required this.quantity,
    required this.temperature,
    required this.acidity,
    required this.quality,
    required this.approved,
    this.indicators,
    this.collectorName,
    this.observations,
  });

  factory ProducerCollectionModel.fromJson(Map<String, dynamic> json) {
    return ProducerCollectionModel(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      acidity: (json['acidity'] as num).toDouble(),
      quality: json['quality'] as String,
      approved: json['approved'] as bool,
      indicators: json['indicators'] != null
          ? QualityIndicators.fromJson(
              json['indicators'] as Map<String, dynamic>,
            )
          : null,
      collectorName: json['collectorName'] as String?,
      observations: json['observations'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'temperature': temperature,
      'acidity': acidity,
      'quality': quality,
      'approved': approved,
      'indicators': indicators?.toJson(),
      'collectorName': collectorName,
      'observations': observations,
    };
  }

  @override
  List<Object?> get props => [
    id,
    date,
    quantity,
    temperature,
    acidity,
    quality,
    approved,
    indicators,
    collectorName,
    observations,
  ];
}
