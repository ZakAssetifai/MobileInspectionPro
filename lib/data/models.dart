import 'package:flutter/material.dart';

enum InspectionStatus { draft, submitted, synced, assigned }

extension InspectionStatusX on InspectionStatus {
  String get label {
    switch (this) {
      case InspectionStatus.draft:
        return 'DRAFT';
      case InspectionStatus.submitted:
        return 'SUBMITTED';
      case InspectionStatus.synced:
        return 'SYNCED';
      case InspectionStatus.assigned:
        return 'ASSIGNED';
    }
  }
}

enum InspectionKind { routine, detailed, damage, emergency }

extension InspectionKindX on InspectionKind {
  String get label {
    switch (this) {
      case InspectionKind.routine:
        return 'ROUTINE';
      case InspectionKind.detailed:
        return 'DETAILED';
      case InspectionKind.damage:
        return 'DAMAGE';
      case InspectionKind.emergency:
        return 'EMERGENCY';
    }
  }

  String get description {
    switch (this) {
      case InspectionKind.routine:
        return 'Periodic visual inspection';
      case InspectionKind.detailed:
        return 'Comprehensive engineering review';
      case InspectionKind.damage:
        return 'Post-event condition check';
      case InspectionKind.emergency:
        return 'Immediate safety assessment';
    }
  }
}

enum AssetKind { bridge, culvert }

extension AssetKindX on AssetKind {
  String get tag => this == AssetKind.bridge ? 'BR' : 'CV';
  String get label => this == AssetKind.bridge ? 'BRIDGE' : 'CULVERT';
}

class Asset {
  final String id;
  final String name;
  final AssetKind kind;
  final String region;
  final String city;
  final int yearBuilt;
  final double length; // meters
  final String material;
  final double lat;
  final double lng;
  final List<String> documents;

  const Asset({
    required this.id,
    required this.name,
    required this.kind,
    required this.region,
    required this.city,
    required this.yearBuilt,
    required this.length,
    required this.material,
    required this.lat,
    required this.lng,
    this.documents = const [],
  });
}

enum WeatherCondition { clear, cloudy, rain, snow, windy }

extension WeatherX on WeatherCondition {
  String get label {
    switch (this) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.windy:
        return 'Windy';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherCondition.clear:
        return Icons.wb_sunny_outlined;
      case WeatherCondition.cloudy:
        return Icons.cloud_outlined;
      case WeatherCondition.rain:
        return Icons.grain;
      case WeatherCondition.snow:
        return Icons.ac_unit;
      case WeatherCondition.windy:
        return Icons.air;
    }
  }
}

enum ConditionRating { excellent, good, fair, poor }

extension ConditionRatingX on ConditionRating {
  int get value => index + 1;
  String get label {
    switch (this) {
      case ConditionRating.excellent:
        return 'EXCELLENT';
      case ConditionRating.good:
        return 'GOOD';
      case ConditionRating.fair:
        return 'FAIR';
      case ConditionRating.poor:
        return 'POOR';
    }
  }

  Color get color {
    switch (this) {
      case ConditionRating.excellent:
        return const Color(0xFF1E5BB8); // primary blue
      case ConditionRating.good:
        return const Color(0xFF16A34A); // green
      case ConditionRating.fair:
        return const Color(0xFFF59E0B); // amber
      case ConditionRating.poor:
        return const Color(0xFFDC2626); // red
    }
  }
}

enum DefectSeverity { low, medium, high, critical }

extension DefectSeverityX on DefectSeverity {
  String get label {
    switch (this) {
      case DefectSeverity.low:
        return 'LOW';
      case DefectSeverity.medium:
        return 'MEDIUM';
      case DefectSeverity.high:
        return 'HIGH';
      case DefectSeverity.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case DefectSeverity.low:
        return const Color(0xFF16A34A);
      case DefectSeverity.medium:
        return const Color(0xFFF59E0B);
      case DefectSeverity.high:
        return const Color(0xFFDC2626);
      case DefectSeverity.critical:
        return const Color(0xFF991B1B);
    }
  }
}

class Defect {
  String label;
  String type;
  DefectSeverity severity;
  int extent;
  String notes;
  String locationDescription;
  String gpsCoordinates;
  bool immediateRisk;
  bool markerPlaced;
  int photoCount;

  Defect({
    required this.type,
    required this.severity,
    this.label = '',
    this.extent = 1,
    this.notes = '',
    this.locationDescription = '',
    this.gpsCoordinates = '',
    this.immediateRisk = false,
    this.markerPlaced = false,
    this.photoCount = 0,
  });
}

class InspectionElement {
  final String code; // e.g. "Deck"
  final String name;
  final String description;
  final bool aiAvailable;
  final List<String> defectTypes;

  ConditionRating? rating;
  bool byInstance;
  List<Defect> defects;
  bool immediateRisk;
  String notes;

  InspectionElement({
    required this.code,
    required this.name,
    required this.description,
    this.aiAvailable = true,
    this.defectTypes = const [],
    this.rating,
    this.byInstance = false,
    List<Defect>? defects,
    this.immediateRisk = false,
    this.notes = '',
  }) : defects = defects ?? [];
}

class Inspection {
  final String id;
  final Asset asset;
  final InspectionKind kind;
  InspectionStatus status;
  WeatherCondition? weather;
  bool accessRestricted;
  String accessNotes;
  List<InspectionElement> elements;
  ConditionRating? overallCondition;
  String inspectorNotes;
  DateTime started;
  DateTime? submitted;
  String inspector;
  int criticalFindings;

  Inspection({
    required this.id,
    required this.asset,
    required this.kind,
    required this.status,
    required this.elements,
    required this.started,
    this.weather,
    this.accessRestricted = false,
    this.accessNotes = '',
    this.overallCondition,
    this.inspectorNotes = '',
    this.submitted,
    this.inspector = 'Zeeshan Khan',
    this.criticalFindings = 0,
  });

  int get ratedCount => elements.where((e) => e.rating != null).length;
  int get totalElements => elements.length;
}
