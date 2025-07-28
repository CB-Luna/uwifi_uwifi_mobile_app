import 'package:equatable/equatable.dart';

/// Modelo para los metadatos JSON de videos
class MetadataJson extends Equatable {
  final int? points;
  final String? status;
  final String? urlAd;
  final String? partner;
  final int? genreId;
  final int? priority;
  final String? sourceTable;
  final int? originalAdId;
  final String? expirationDate;
  final int? durationSeconds;

  const MetadataJson({
    this.points,
    this.status,
    this.urlAd,
    this.partner,
    this.genreId,
    this.priority,
    this.sourceTable,
    this.originalAdId,
    this.expirationDate,
    this.durationSeconds,
  });

  /// Crea una instancia de [MetadataJson] a partir de un mapa JSON
  factory MetadataJson.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MetadataJson();
    }
    
    return MetadataJson(
      points: json['points'],
      status: json['status'],
      urlAd: json['url_ad'],
      partner: json['partner'],
      genreId: json['genre_id'],
      priority: json['priority'],
      sourceTable: json['source_table'],
      originalAdId: json['original_ad_id'],
      expirationDate: json['expiration_date'],
      durationSeconds: json['duration_seconds'],
    );
  }

  /// Convierte esta instancia a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'status': status,
      'url_ad': urlAd,
      'partner': partner,
      'genre_id': genreId,
      'priority': priority,
      'source_table': sourceTable,
      'original_ad_id': originalAdId,
      'expiration_date': expirationDate,
      'duration_seconds': durationSeconds,
    };
  }

  @override
  List<Object?> get props => [
        points,
        status,
        urlAd,
        partner,
        genreId,
        priority,
        sourceTable,
        originalAdId,
        expirationDate,
        durationSeconds,
      ];
}
